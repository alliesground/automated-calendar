class GoogleCalendarConfigsController < ApplicationController
  def new
  end

  def create
    client = GoogleCalWrapper.new(current_user).client

    redirect_to client.authorization_uri.to_s
  end

  def destroy
    current_user.google_calendar_config.delete
  end

  def callback
    client = GoogleCalWrapper.new(current_user).client
    client.code = params[:code]
    response = client.fetch_access_token!

    current_user.create_google_calendar_config(authorization: response)

    redirect_to google_calendars_path
  end
end
