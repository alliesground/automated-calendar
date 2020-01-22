class GoogleCalendarsController < ApplicationController

  def index
    google_cal_wrapper = GoogleCalWrapper.new(current_user)
    @calendar_list = google_cal_wrapper.list_calendar_lists
  end

  def new
    @google_calendar = GoogleCalendar.new
  end

  def create
    @google_calendar = current_user.google_calendars.build(google_calendar_params)

    if @google_calendar.save
      flash[:notice] = 'Calendar created successfully'

      GoogleCalendarWorker.perform_async(@google_calendar.id, @google_calendar.name, current_user.id)
      redirect_to google_calendars_path
    else
      response.set_header('Message', 'Please fill up the required fields')
    end
  end

  private

  def google_calendar_params
    params.require(:google_calendar).permit(
      :name,
      :description
    )
  end
end
