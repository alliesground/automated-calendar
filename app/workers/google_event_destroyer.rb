class GoogleEventDestroyer
  require_relative '../../lib/google_cal_wrapper.rb'

  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  def perform(user_id, google_cal_remote_id, google_event_remote_id)

    user = User.find_by(id: user_id)

    google_cal_wrapper = GoogleCalWrapper.new(user)

    google_cal_wrapper.delete_event(
      google_cal_remote_id,
      google_event_remote_id
    )
  end
end
