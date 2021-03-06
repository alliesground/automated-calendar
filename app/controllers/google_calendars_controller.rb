class GoogleCalendarsController < ApplicationController

  def index
    @google_calendars = current_user.google_calendars
  end

  def new
    @google_calendar = GoogleCalendar.new
  end

  def create
    @google_calendar = current_user.google_calendars.build(google_calendar_params)

    if @google_calendar.save
      flash[:notice] = 'Calendar created successfully'
      redirect_to google_calendars_path

      return unless GoogleCalendarConfig.authorized_by?(current_user)

      GoogleCalendarCreator.perform_async(@google_calendar.id, @google_calendar.name, current_user.id)
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
