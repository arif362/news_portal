FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :reader }
    active { true }

    trait :admin do
      role { :admin }
    end

    trait :editor do
      role { :editor }
    end

    trait :author do
      role { :author }
    end

    trait :inactive do
      active { false }
    end
  end
end
