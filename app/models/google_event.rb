class GoogleEvent < ApplicationRecord
  belongs_to :event
  belongs_to :google_calendar
end
