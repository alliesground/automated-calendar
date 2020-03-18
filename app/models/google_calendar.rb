class GoogleCalendar < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: {case_sensitive: false, scope: :user_id}

  has_many :google_events
  has_many :outbound_event_configs

  scope :by_lowercase_name, -> (name) { where("lower(name) = ?", name.downcase) }
end
