class Event < ApplicationRecord
  belongs_to :user
  has_many :google_events, dependent: :destroy

  validates_presence_of :title
end
