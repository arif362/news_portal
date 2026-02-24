FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.paragraph }
    association :article, :published
    association :user
    status { :pending }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :with_reply do
      after(:create) do |comment|
        create(:comment, :approved, article: comment.article, parent: comment)
      end
    end
  end
end
