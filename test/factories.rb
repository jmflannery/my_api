FactoryBot.define do
  factory :token do
  end

  factory :user do
    email { Faker::Internet.email }
    password { "secret" }
    password_confirmation { "secret" }
    name { Faker::Name.name }
  end
end
