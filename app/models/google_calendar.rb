class GoogleCalendar < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :user
end
