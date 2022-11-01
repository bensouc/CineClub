class EventsController < ApplicationController
  def index
    @events = Event.all.order(date: :desc)
  end

  def show
    @event = Event.find(params[:id])
    @choices = @event.choices.order(ranking: :desc)
    # raise
    @movies = @event.movies
    @votes_user = Vote.where(user: current_user)
  end

  def add_movie
    @event = Event.find(params[:id])
    movie = Movie.find_or_create_movie(params_movie)
    movie.update(params_movie)
    Choice.create(movie: movie, user: current_user, event: @event, ranking: 0)
    redirect_to event_path(@event)
  end



  private

  def params_movie
    # kind_id = params.require(:tmdb_genre_id)
    {
      title: params.require(:title),
      kind: params.require(:tmdb_genre_id),
      poster_url: "https://image.tmdb.org/t/p/w300#{params.require(:tmdb_poster_url)}",
      tmdb_id: params.require(:tmdb_id),
      year: params.require(:year),
      overview: params.require(:tmdb_overview)
    }
  end
end
