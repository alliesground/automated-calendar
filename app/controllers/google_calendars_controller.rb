class GoogleCalendarsController < ApplicationController
  def index
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(current_user.google_calendar_config.authorization)

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    begin
      @calendar_list = service.list_calendar_lists
    rescue Google::Apis::AuthorizationError
      response = client.refresh!
      current_user.google_calendar_config.authorization.merge(response)
      retry
    end
  end
end
