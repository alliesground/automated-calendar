class EventsController < ApplicationController
  def new
    @event = Event.new
  end

  def create
#    @event = current_user.events.build(
#      event_params.merge(
#        start_time: start_date_time,
#        end_time: end_date_time
#      )
#    )

    @event = current_user.events.build(event_params)

    if @event.save
      flash[:success] = 'Event saved'
    else
      flash[:error] = 'Something went wrong'
    end
  end

  private

  def start_date_time
    return if params[:start_date].empty? || params[:start_time].empty?

    start_date = Date.parse(params[:start_date])
    start_time = Time.parse(params[:start_time])

    (start_date + start_time.seconds_since_midnight.seconds).to_datetime
  end

  def end_date_time
    return if params[:end_date].empty? || params[:end_time].empty?

    end_date = Date.parse(params[:end_date])
    end_time = Time.parse(params[:end_time])
    (end_date + end_time.seconds_since_midnight.seconds).to_datetime
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
