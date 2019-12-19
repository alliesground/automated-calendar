class EventsController < ApplicationController
  before_action :set_event, only: [:update]

  def index
    events = current_user.events
    @presented_events = events.map do |event|
      event_presenter(event)
    end
  end

  def edit 
    event = current_user.events.find_by_id(params[:id])
    event_presenter(event)
  end 

  def update
    respond_to do |format|
      if @event.update(event_params)
        flash.now[:notice] = 'Event updated successfully'
      else
        format.js {render partial: 'form_errors'}
      end
    end
  end

  def new
    event = Event.new
    event_presenter(event)
  end

  def create
    @event = current_user.events.build(event_params)

    respond_to do |format|
      if @event.save
        redirect_to events_path
        flash[:notice] = 'Event saved'
      else
        format.js { render partial: 'form_errors' }
      end
    end
  end

  private

  def event_presenter(event)
    @presented_event = EventPresenter.new(event)
  end

  def set_event
    @event = Event.find_by_id(params[:id])
  end

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
