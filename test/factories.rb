FactoryBot.define do
  factory :token do
  end

  factory :user do
    email { Faker::Internet.email }
    password { "secret" }
    password_confirmation { "secret" }
    name { Faker::Name.name }
  end

  factory :post do

    title { @base_title = "How to write #{Faker::ProgrammingLanguage.name} like a pro" }
    slug { @base_title.downcase.gsub(/\W/, '-') }
    body { Faker::Lorem.paragraphs(number: 3).join("\n") }
    published_at { nil }
    last_edited_at { nil }

    trait :published do
      published_at { 1.week.ago }
    end

    trait :published_future do
      published_at { 1.week.from_now }
    end

    trait :edited do
      last_edited_at { 1.day.ago }
    end

    factory :published_post, traits: [:published]
    factory :published_in_future_post, traits: [:published_future]
    factory :edited_post,    traits: [:published, :edited]
  end
end
