class GoogleEventUpdater
  require_relative '../../lib/google_cal_wrapper.rb'

  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  attr_reader :event_receiver

  def perform(event_id, google_cal_remote_id, google_event_remote_id, event_receiver_id)

    event = Event.find_by(id: event_id)
    @event_receiver = User.find_by(id: event_receiver_id)

    google_cal_wrapper = GoogleCalWrapper.new(event_receiver)

    remote_event = google_cal_wrapper.get_event(
      google_cal_remote_id, 
      google_event_remote_id
    )

    remote_event.summary = event.title

    result = google_cal_wrapper.update_event(
      google_cal_remote_id,
      google_event_remote_id,
      remote_event
    )

    print result.updated
  end
end
