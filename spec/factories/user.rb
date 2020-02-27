FactoryBot.define do
  factory :user, aliases: [:owner, :receiver] do
    email {"test@email.com"}
    password {"password"}
    password_confirmation {"password"}
  end
end
