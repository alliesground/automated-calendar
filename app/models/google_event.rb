class GoogleEvent < ApplicationRecord
  belongs_to :event
  belongs_to :google_calendar

  scope :find_by_user, ->(user) { where(google_calendar_id: user.google_calendars.ids) }

end
