class ChoicesController < ApplicationController
  before_action :set_event, only: [:create, :vote, :unvote]

  # Adds the TMDB movie identified by `tmdb_id` to the event. Only the id comes
  # from the browser — every other detail is fetched from TMDB server-side, so
  # nothing user-supplied ends up in the movies table.
  def create
    movie = Movie.find_or_create_from_tmdb(params.require(:tmdb_id))
    return back_to_event("Ce film est introuvable sur TMDB.") if movie.nil?
    return back_to_event(movie.errors.full_messages.to_sentence) unless movie.persisted?

    choice = Choice.new(movie: movie, user: current_user, event: @event, ranking: 0)
    choice.save
    back_to_event(choice.errors.full_messages.to_sentence.presence)
  rescue TmdbClient::Error => e
    Rails.logger.error("TMDB lookup failed while adding a movie: #{e.message}")
    back_to_event("TMDB est momentanément indisponible.")
  end

  def vote
    choice = Choice.find(params[:id])
    Vote.create(user: current_user, choice: choice)
    refresh_ranking(choice)
    back_to_event
  end

  def unvote
    choice = Choice.find(params[:id])
    Vote.where(user: current_user, choice: choice).destroy_all
    refresh_ranking(choice)
    back_to_event
  end

  def destroy
    choice = Choice.find(params[:id])
    @event = choice.event
    choice.destroy
    back_to_event
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  # ranking is a denormalised vote count, so it has to be recomputed whenever a
  # vote appears or disappears.
  def refresh_ranking(choice)
    choice.update(ranking: choice.votes.count)
  end

  def back_to_event(alert = nil)
    redirect_to @event, alert: alert
  end
end
