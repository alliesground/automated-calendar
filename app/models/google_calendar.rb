class GoogleCalendar < ApplicationRecord
  belongs_to :user

  validates_presence_of :name
  has_many :google_events
end
