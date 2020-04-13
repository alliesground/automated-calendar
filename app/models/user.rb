class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :google_calendar_config
  has_many :events
  has_many :google_calendars
  has_many :outbound_event_configs, foreign_key: 'owner_id'

  def outbound_event_configs_for(google_calendar)
    outbound_event_configs.by_google_calendar(google_calendar)
  end

  def has_google_calendar_with_name?(calendar_name)
    google_calendars.by_lowercase_name(calendar_name).present?
  end
end
