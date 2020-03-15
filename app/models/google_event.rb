class GoogleEvent < ApplicationRecord
  belongs_to :event
  belongs_to :google_calendar

  scope :find_by_user_google_calendars, ->(user_google_calendars) { where(google_calendar_id: user_google_calendars) }

end
