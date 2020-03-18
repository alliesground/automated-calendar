class Event < ApplicationRecord
  belongs_to :user
  has_many :google_events, dependent: :destroy

  validates_presence_of :title

  def google_events_for(user)
    google_events.by_user(user)
  end
end
