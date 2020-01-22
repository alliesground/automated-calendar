class GoogleCalWrapper
  include Rails.application.routes.url_helpers

  attr_reader :user

  def initialize(user)
    @user = user
    client.update!(user.google_calendar_config.authorization)
    service.authorization = client
  end

  def list_calendar_lists
    get_service do |service|
      service.list_calendar_lists
    end
  end

  def insert_calendar(calendar)
    get_service do |service|
      service.insert_calendar(calendar)
    end
  end

  def insert_event(cal_id, event)
    get_service do |service|
      service.insert_event(
        cal_id,
        event
      )
    end
  end

  private

  def get_service
    begin
      yield service
    rescue Google::Apis::AuthorizationError
      response = client.refresh!
      user.google_calendar_config.authorization.merge(response)
      retry
    end
  end

  def client
    @client ||= Signet::OAuth2::Client.new(client_options)
  end

  def service
    @service ||= Google::Apis::CalendarV3::CalendarService.new
  end

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
end
