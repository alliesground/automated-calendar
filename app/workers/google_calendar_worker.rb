class GoogleCalendarWorker
  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  attr_reader :user

  def perform(id, name, user_id)
    @user = User.find_by(id: user_id)

    calendar = Google::Apis::CalendarV3::Calendar.new(
      summary: name
    )

    client.update!(user.google_calendar_config.authorization)
    service.authorization = client

    begin
      response = service.insert_calendar(calendar)
      google_calendar = GoogleCalendar.find_by(id: id)
      google_calendar&.update(remote_id: response.id)
    rescue Google::Apis::AuthorizationError
      response = client.refresh!
      user.google_calendar_config.authorization.merge(response)
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
