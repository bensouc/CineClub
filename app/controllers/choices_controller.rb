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
      redirect_to event_path(@event)
    else
      redirect_to event_path(@event)
    end
  end

  def unvote
    @event = Event.find(params_event)
    @choice = Choice.find(params[:id])
    @vote = Vote.where(user: current_user, choice: @choice).first
    @vote.destroy
    @choice.ranking = @choice.votes.count
    @choice.save
    redirect_to event_path(@event)
  end

  def destroy
    @choice = Choice.find(params[:id])
    @event = @choice.event
    @choice.destroy
    redirect_to event_path(@event)
  end

  private

  def params_event
    params.required(:event_id)
  end
end
