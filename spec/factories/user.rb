require 'faker'

FactoryBot.define do
  factory :user, aliases: [:owner, :receiver] do
    email {Faker::Internet.email}
    password {"password"}
    password_confirmation {"password"}
  end
end
