class Event < ApplicationRecord
  attr_accessor :event_start_date, :event_end_date, :event_start_time, :event_end_time

  belongs_to :user

  validates_presence_of :title,
                        :event_start_date,
                        :event_start_time,
                        :event_end_date,
                        :event_end_time

  #after_save :save_date_time

  private

  def save_date_time
    self.start_time = start_date_time
  end

  def start_date_time
    start_date = Date.parse(event_start_date)
    start_time = Time.parse(event_start_time)
  end
end
