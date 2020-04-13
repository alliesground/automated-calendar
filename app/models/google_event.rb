class GoogleEvent < ApplicationRecord
  belongs_to :event
  belongs_to :google_calendar

  before_destroy :destroy_remote_google_event
  after_create_commit :create_remote_google_event 

  scope :by_calendar_name, -> (calendar_name) {
    where(google_calendar_id:  GoogleCalendar.by_lowercase_name(calendar_name).ids)
  }

  scope :by_user, -> (user) { where(google_calendar_id: user.google_calendars.ids) }

  scope :by_user_and_calendar_name, -> (user, calendar_name) {
    joins(:google_calendar).
    merge(by_user(user)).
    merge(GoogleCalendar.by_lowercase_name(calendar_name)).
    last
  }

  def user
    google_calendar.user
  end

  private

  def create_remote_google_event
    GoogleEventCreator.perform_async(id)
  end

  def destroy_remote_google_event
    return unless GoogleCalendarConfig.authorized_by?(user)

    GoogleEventDestroyer.perform_async(
      user.id,
      google_calendar.remote_id,
      remote_id
    )
  end
end
