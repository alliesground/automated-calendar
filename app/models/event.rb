class Event < ApplicationRecord
  belongs_to :user
  has_one :google_event, dependent: :destroy

  validates_presence_of :title
end
