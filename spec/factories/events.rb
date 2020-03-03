FactoryBot.define do
  factory :event do
    title {'test event'}
    start_time {Time.zone.now}
    end_time {Time.zone.now}
    user
  end
end
