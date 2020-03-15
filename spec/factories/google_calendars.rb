FactoryBot.define do
  factory :google_calendar do
    user
    name {'test calendar'}
    description {'testing google calendar'}
    remote_id {'123ABC-google-calendar'}
  end
end
