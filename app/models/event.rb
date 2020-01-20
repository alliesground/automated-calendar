class Event < ApplicationRecord
  belongs_to :user
  has_one :google_event

  validates_presence_of :title
end
