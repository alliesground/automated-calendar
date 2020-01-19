class Event < ApplicationRecord
  attr_accessor :event_start_date, :event_end_date, :event_start_time, :event_end_time

  belongs_to :user
  has_one :google_event

  validates_presence_of :title,
                        :event_start_date,
                        :event_start_time,
                        :event_end_date,
                        :event_end_time

  before_save :save_start_time, :save_end_time

  private

  def save_start_time
    date = Time.zone.parse(event_start_date)
    time = Time.zone.parse(event_start_time)
    self.start_time = Time.zone.parse("#{date.strftime('%F')} #{time.strftime('%T')}")
  end

  def save_end_time
    date = Time.zone.parse(event_end_date)
    time = Time.zone.parse(event_end_time)
    self.end_time = Time.zone.parse("#{date.strftime('%F')} #{time.strftime('%T')}")
  end
end
