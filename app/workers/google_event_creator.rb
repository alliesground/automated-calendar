class GoogleEventCreator
  require_relative '../../lib/google_cal_wrapper.rb'

  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  attr_reader :event_receiver

  def perform(event_id, google_cal_remote_id, event_receiver_id)

    time_zone = 'Australia/Melbourne'
    event = Event.find_by(id: event_id)
    @event_receiver = User.find_by(id: event_receiver_id)

    google_cal_wrapper = GoogleCalWrapper.new(event_receiver)

    remote_event = Google::Apis::CalendarV3::Event.new(
      summary: event.title,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: event.start_time.strftime('%Y-%m-%dT%H:%M:%S'),
        time_zone: time_zone
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: event.end_time.strftime('%Y-%m-%dT%H:%M:%S'),
        time_zone: time_zone
      )
    )

    response = google_cal_wrapper.insert_event(
      google_cal_remote_id,
      remote_event
    )

    event.google_event.update(remote_id: response.id)
  end
end
