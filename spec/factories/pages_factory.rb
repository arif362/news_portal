FactoryBot.define do
  factory :page do
    sequence(:title) { |n| "Page Title #{n}" }
    body { Faker::Lorem.paragraphs(number: 3).map { |p| "<p>#{p}</p>" }.join }
    status { :draft }
    position { 0 }
    show_in_navigation { false }
    association :author, factory: :user, role: :admin

    trait :published do
      status { :published }
    end

    trait :navigation do
      published
      show_in_navigation { true }
    end
  end
end
