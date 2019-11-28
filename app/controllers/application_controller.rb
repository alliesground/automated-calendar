class ApplicationController < ActionController::Base
  before_action :authenticate_user!

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
end
