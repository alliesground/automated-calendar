class Event < ApplicationRecord
  belongs_to :user
  has_many :google_events, dependent: :destroy

  validates_presence_of :title

  def google_events_for(user_google_calendars)
    google_events.find_by_user_google_calendars(user_google_calendars)
  end
end
