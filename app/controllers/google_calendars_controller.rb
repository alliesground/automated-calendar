class GoogleCalendarsController < ApplicationController

  def index
    @google_calendars = GoogleCalendar.all
#    get_service do |service|
#      @calendar_list = service.list_calendar_lists
#    end
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

  def get_service
    client.update!(current_user.google_calendar_config.authorization)
    service.authorization = client

    begin
      yield service
    rescue Google::Apis::AuthorizationError
      response = client.refresh!
      current_user.google_calendar_config.authorization.merge(response)
      retry
    end
  end

  def google_calendar_params
    params.require(:google_calendar).permit(
      :name,
      :description
    )
  end

  def client
    @client ||= Signet::OAuth2::Client.new(client_options)
  end

  def service
    @service ||= Google::Apis::CalendarV3::CalendarService.new
  end
end
