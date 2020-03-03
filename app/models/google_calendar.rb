class GoogleCalendar < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: {case_sensitive: false, scope: :user_id}

  has_many :google_events
  has_many :outbound_event_configs

  scope :find_by_lowercase_name, -> (name) { where("lower(name) = ?", name.downcase) }

  def self.exist_with_name?(name)
    find_by_lowercase_name(name).exists?
  end
end
