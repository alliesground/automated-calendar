class GoogleCalendar < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  has_many :google_events
  has_many :outbound_event_configs
end
