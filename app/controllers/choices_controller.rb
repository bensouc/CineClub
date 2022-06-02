class ChoicesController < ApplicationController
  def vote
    @event = Event.find(params_event)
    @choice = Choice.find(params[:id])
    @choice.ranking += 1
    @choice.save
    redirect_to event_path(@event)
  end

  private

  def params_event
  params.required(:event_id)
  end
end
