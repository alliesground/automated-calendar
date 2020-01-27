class OutboundEventConfig < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  belongs_to :google_calendar

  validates :receiver_id, uniqueness: { scope: :google_calendar_id }
end
