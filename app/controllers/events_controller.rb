class EventsController < ApplicationController
  before_action :set_event, only: [:update, :destroy]

  def index
    @events = current_user.events
    @presented_events = @events.map do |event|
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
        format.js do
          flash[:notice] = 'Event updated successfully'
          redirect_to events_path
        end
      else
        format.js do
          set_message('Please fill the required fields')
          render partial: 'form_errors', 
                 status: 400

        end
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
        format.js do
          flash[:notice] = 'Event saved'
          redirect_to events_path
        end
      else
        format.js do 
          set_message('Please fill up the required fields')

          render partial: 'form_errors',
          status: 400
        end
      end
    end
  end

  def destroy
    @event.destroy

    if @event.destroyed?
      flash[:notice] = "Event #{ @event.title} was deleted successfully"
    else
      flash[:notice] = "Event #{@event.title} could not be deleted"
    end

    redirect_to events_path
  end

  private

  def set_message(msg)
    response.set_header('Message', msg)
  end

  def event_presenter(event)
    @presented_event = EventPresenter.new(event)
  end

  def set_event
    @event = current_user.events.find_by_id(params[:id])
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
