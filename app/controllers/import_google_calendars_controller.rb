class ImportGoogleCalendarsController < ApplicationController

  def index
    if GoogleCalendarConfig.authorized_by?(current_user)
      google_cal_wrapper = GoogleCalWrapper.new(current_user)
      @calendar_list = google_cal_wrapper.list_calendar_lists

      @calendar_list.items.each do |calendar|
        current_user.google_calendars.where(remote_id: calendar.id)
          .first_or_create do |google_calendar|
          google_calendar.name = calendar.summary
          google_calendar.remote_id = calendar.id
        end
      end
    end

    redirect_to google_calendars_path
  end
end
