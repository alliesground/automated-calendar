class GoogleCalendarConfigsController < ApplicationController
  def new
  end

  def create
    client = Signet::OAuth2::Client.new(client_options)

    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]

    response = client.fetch_access_token!

    current_user.create_google_calendar_config(authorization: response)

    redirect_to google_calendars_path
  end
end
