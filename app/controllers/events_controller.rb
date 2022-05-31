class EventsController < ApplicationController
  def index
    @events = Event.all
  end
  def show
    @event = Event.find(params[:id])
    @choices = @event.choices.order(ranking: :desc)
    @movies = @event.movies
  end
end
