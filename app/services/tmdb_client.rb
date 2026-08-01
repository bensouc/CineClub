# frozen_string_literal: true

require "net/http"

# Thin wrapper around the TMDB v3 REST API.
#
# The API key lives in Rails credentials (`tmdb.api_key`) and never reaches the
# browser: the search box calls MoviesController#search, which calls this class.
class TmdbClient
  # Raised whenever we cannot get a usable answer out of TMDB — no API key
  # configured, a timeout, a non-success response, or a body we cannot parse.
  class Error < StandardError; end

  BASE_URL = "https://api.themoviedb.org/3"
  POSTER_BASE_URL = "https://image.tmdb.org/t/p/w300"
  LANGUAGE = "fr"

  OPEN_TIMEOUT = 2
  READ_TIMEOUT = 5

  class << self
    # Movies matching `query`, shaped for the search results grid.
    #
    # Results without a poster are dropped: the grid is nothing but posters, and
    # Movie requires a poster_url, so they could never be added anyway.
    def search(query)
      query = query.to_s.strip
      return [] if query.empty?

      body = get("search/movie", query: query, include_adult: "false")

      Array(body["results"]).filter_map do |result|
        next if result["poster_path"].blank?

        {
          tmdb_id: result["id"],
          title: title_for(result),
          poster_url: poster_url(result["poster_path"]),
          year: result["release_date"].to_s[0, 4].presence
        }
      end
    end

    # Everything we persist about a movie, as Movie attributes.
    # Returns nil when TMDB has no movie with that id.
    #
    # `append_to_response` nests the trailer list and the credits inside the
    # movie payload, so this costs one HTTPS round-trip rather than three.
    def movie_details(tmdb_id)
      tmdb_id = coerce_id(tmdb_id)
      return nil if tmdb_id.nil?

      body = get("movie/#{tmdb_id}", append_to_response: "videos,credits")
      return nil if body.nil?

      {
        tmdb_id: tmdb_id,
        title: title_for(body),
        poster_url: poster_url(body["poster_path"]),
        # TMDB localises the genre names for us, so there is nothing to map.
        kind: Array(body["genres"]).filter_map { |genre| genre["name"].presence }.join(", "),
        year: body["release_date"].presence,
        overview: body["overview"].to_s,
        director: director_for(body.dig("credits", "crew")),
        trailer_url: youtube_trailer_url(body.dig("videos", "results"))
      }
    end

    # A YouTube trailer link for the movie, or nil when there is none.
    #
    # A missing trailer is never a reason to fail adding a movie, so network and
    # API errors are swallowed here rather than raised.
    def trailer_url(tmdb_id)
      tmdb_id = coerce_id(tmdb_id)
      return nil if tmdb_id.nil?

      body = get("movie/#{tmdb_id}/videos")
      return nil if body.nil?

      youtube_trailer_url(body["results"])
    rescue Error => e
      Rails.logger.warn("TMDB trailer lookup failed for #{tmdb_id.inspect}: #{e.message}")
      nil
    end

    private

    # TMDB ids are integers; anything else is not a movie we can look up.
    def coerce_id(value)
      Integer(value)
    rescue ArgumentError, TypeError
      nil
    end

    # TMDB omits the localised title for some films; fall back to the original.
    def title_for(body)
      body["title"].presence || body["original_title"].to_s
    end

    # First person credited as "Director" in the crew, or nil.
    def director_for(crew)
      Array(crew).find { |member| member["job"] == "Director" }&.dig("name").presence
    end

    def youtube_trailer_url(results)
      videos = Array(results).select { |video| video["site"] == "YouTube" && video["key"].present? }
      video = videos.find { |v| v["type"] == "Trailer" } || videos.first
      return nil if video.nil?

      "https://www.youtube.com/watch?v=#{video['key']}"
    end

    def poster_url(poster_path)
      return nil if poster_path.blank?

      "#{POSTER_BASE_URL}#{poster_path}"
    end

    def api_key
      key = Rails.application.credentials.dig(:tmdb, :api_key).presence
      raise Error, "no TMDB API key configured (credentials: tmdb.api_key)" if key.nil?

      key
    end

    # Performs the request and returns the parsed body, or nil on a 404.
    def get(path, **params)
      uri = URI.parse("#{BASE_URL}/#{path}")
      uri.query = URI.encode_www_form(params.merge(api_key: api_key, language: LANGUAGE))

      response = perform(uri)

      case response
      when Net::HTTPSuccess  then parse(response.body)
      when Net::HTTPNotFound then nil
      else
        raise Error, "TMDB responded #{response.code} for /#{path}"
      end
    end

    def perform(uri)
      Net::HTTP.start(
        uri.host, uri.port,
        use_ssl: true,
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT
      ) { |http| http.request(Net::HTTP::Get.new(uri)) }
    rescue Timeout::Error, IOError, SystemCallError, OpenSSL::SSL::SSLError => e
      raise Error, "TMDB request failed: #{e.class}: #{e.message}"
    end

    def parse(body)
      JSON.parse(body.to_s)
    rescue JSON::ParserError => e
      raise Error, "TMDB returned invalid JSON: #{e.message}"
    end
  end
end
