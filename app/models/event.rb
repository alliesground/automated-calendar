class Event < ApplicationRecord
  belongs_to :user
  has_many :google_events, dependent: :destroy

  validates_presence_of :title

  def google_calendar_ids_for(user)
    google_events_for(user).map(&:google_calendar_id)
  end

  def google_events_for(user)
    google_events.find_by_user(user)
  end
end
