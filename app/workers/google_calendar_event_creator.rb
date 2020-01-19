class GoogleCalendarEventCreator
  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  attr_reader :owner

  def perform(event_id, google_cal_id, owner_id)
    time_zone = 'Australia/Melbourne'
    event = Event.find_by(id: event_id)
    google_calendar = GoogleCalendar.find_by(id: google_cal_id)
    @owner = User.find_by(id: owner_id)

    remote_event = Google::Apis::CalendarV3::Event.new(
      summary: event.title,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: event.start_time.strftime('%Y-%m-%dT%H:%M:%S'),
        time_zone: time_zone
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: event.end_time.strftime('%Y-%m-%dT%H:%M:%S'),
        time_zone: time_zone
      )
    )

    client.update!(owner.google_calendar_config.authorization)
    service.authorization = client

    begin
      response = service.insert_event(
        google_calendar.remote_id, 
        remote_event
      )

      event.google_event.update(remote_id: response.id)
    rescue Google::Apis::AuthorizationError
      response = client.refresh!
      owner.google_calendar_config.authorization.merge(response)
      retry
    end
  end

  private

  def client_options
    {
      client_id: Rails.application.credentials.google_OAuth[:client_id],
      client_secret: Rails.application.credentials.google_OAuth[:client_secret],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: google_oauth_callback_url
    }
  end

  def client
    @client ||= Signet::OAuth2::Client.new(client_options)
  end

  def service
    @service ||= Google::Apis::CalendarV3::CalendarService.new
  end
end
