class ChoicesController < ApplicationController
  def vote
    @event = Event.find(params_event)
    @choice = Choice.find(params[:id])
    # @choice.ranking += 1
    # @choice.save
    vote = Vote.new(user: current_user, choice: @choice)
    if vote.save
      @choice.ranking = @choice.votes.count

      @choice.save
      redirect_to event_path(@event), notice: "A voté"
    else
      redirect_to event_path(@event), notice: "On ne vote qu'une fois :)"
    end
  end

  private

  def params_event
    params.required(:event_id)
  end
end
