class GoogleCalendarsController < ApplicationController

  def index
    get_service do |service|
      @calendar_list = service.list_calendar_lists
    end
  end

  def new
    @google_calendar = GoogleCalendar.new
  end

  def create
    calendar = Google::Apis::CalendarV3::Calendar.new(
      summary: params[:google_calendar][:name]
    )

    get_service do |service|
      response = service.insert_calendar(calendar)
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
