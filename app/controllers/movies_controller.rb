class MoviesController < ApplicationController
  # JSON proxy in front of TMDB's search endpoint. It exists so the API key
  # stays on the server instead of being shipped in the JavaScript bundle;
  # authentication is inherited from ApplicationController.
  def search
    render json: { results: TmdbClient.search(params[:query]) }
  rescue TmdbClient::Error => e
    Rails.logger.error("TMDB search failed: #{e.message}")
    render json: { error: "La recherche est momentanément indisponible." },
           status: :bad_gateway
  end
end
