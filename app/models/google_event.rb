class GoogleEvent < ApplicationRecord
  belongs_to :event
  belongs_to :google_calendar

  scope :by_calendar_name, -> (calendar_name) {
    where(google_calendar_id:  GoogleCalendar.by_lowercase_name(calendar_name).ids)
  }

  scope :by_user_and_calendar_name, -> (user, calendar_name) {
    joins(:google_calendar).
    merge(by_user(user)).
    merge(GoogleCalendar.by_lowercase_name(calendar_name))
  }

  scope :by_user, -> (user) { where(google_calendar_id: user.google_calendars.ids) }

  def user
    google_calendar.user
  end
end
