FactoryBot.define do
  factory :advertisement do
    sequence(:title) { |n| "Ad Campaign #{n}" }
    ad_type { :image }
    placement { :top_banner }
    target_url { "https://example.com/landing" }
    status { :draft }

    trait :active do
      status { :active }
      starts_at { 1.day.ago }
      ends_at { 30.days.from_now }
    end

    trait :paused do
      status { :paused }
    end

    trait :expired do
      status { :expired }
      starts_at { 60.days.ago }
      ends_at { 1.day.ago }
    end

    trait :sidebar do
      placement { :sidebar }
    end

    trait :in_feed do
      placement { :in_feed }
    end

    trait :popup do
      placement { :popup }
    end

    trait :html_ad do
      ad_type { :html }
      embed_code { "<div class='ad'>Sponsored Content</div>" }
      target_url { nil }
    end

    trait :with_stats do
      impressions_count { 1000 }
      clicks_count { 25 }
    end
  end
end
