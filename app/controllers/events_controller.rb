class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @events = Event.includes(choices: :movie).order(date: :desc)
  end

  def show
    @choices = @event.choices.includes(:user, :movie, votes: :user).order(ranking: :desc)
    @voted_choice_ids = Vote.where(user: current_user, choice: @choices).pluck(:choice_id).to_set
  end

  def new
    @event = Event.new(date: Date.current)
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to @event, notice: "Soirée créée."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Soirée mise à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Soirée supprimée."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :date)
  end
end
