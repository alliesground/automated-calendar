class EventsController < ApplicationController
  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)

    respond_to do |format|
      if @event.save
        redirect_to events_path
        flash[:notice] = 'Event saved'
      end

      format.js
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :title,
      :event_start_date,
      :event_start_time,
      :event_end_date,
      :event_end_time
    )
  end
end
