FactoryBot.define do
  factory :outbound_event_config do
    owner
    google_calendar
    receiver
  end
end
