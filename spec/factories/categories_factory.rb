FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    description { Faker::Lorem.sentence }
    active { true }
    position { 0 }

    trait :inactive do
      active { false }
    end

    trait :with_parent do
      association :parent, factory: :category
    end
  end
end
