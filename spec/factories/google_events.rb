FactoryBot.define do
  factory :google_event do
    remote_id {'123ABC-google-event'}
    event
    google_calendar
  end
end
