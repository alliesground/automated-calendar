class GoogleCalendarCreator
  require_relative '../../lib/google_cal_wrapper.rb'

  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  attr_reader :owner

  def perform(id, name, owner_id)
    @owner = User.find_by(id: owner_id)
    google_cal_wrapper = GoogleCalWrapper.new(owner)

    calendar = Google::Apis::CalendarV3::Calendar.new(
      summary: name
    )

    google_cal_wrapper.insert_calendar(calendar)

  end
end
