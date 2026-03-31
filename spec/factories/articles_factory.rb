FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article Title #{n}" }
    excerpt { Faker::Lorem.paragraph(sentence_count: 2) }
    body_en { Faker::Lorem.paragraphs(number: 3).map { |p| "<p>#{p}</p>" }.join }
    status { :draft }
    comments_enabled { true }
    association :category
    association :author, factory: :user, role: :author

    trait :published do
      status { :published }
      published_at { Time.current }
    end

    trait :archived do
      status { :archived }
    end

    trait :featured do
      published
      featured { true }
    end

    trait :breaking do
      published
      breaking { true }
    end
  end
end
