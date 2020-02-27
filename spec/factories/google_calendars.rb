FactoryBot.define do
  factory :google_calendar do
    user
    name {'test calendar'}
    description {'testing google calendar'}
  end
end
