class OutboundEventConfig < ActiveRecord
  belongs_to :owner
  belongs_to :receiver
  belongs_to :google_calendar
end
