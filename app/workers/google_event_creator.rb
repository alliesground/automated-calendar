class GoogleEventCreator
  require_relative '../../lib/google_cal_wrapper.rb'

  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  def perform(google_event_id)

    time_zone = 'Australia/Melbourne'
    
    google_event = GoogleEvent.find_by(id: google_event_id)

    event = google_event.event
    event_receiver = google_event.user
    google_calendar = google_event.google_calendar

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
      google_calendar.remote_id,
      remote_event
    )

    event.google_events.update(remote_id: response.id)
  end
end
