require "faker"

puts "Seeding database..."

# Helper: find record by JSONB translated name column, or create it
def find_or_create_translated!(klass, column, en_value, &block)
  record = klass.where("#{column}->>'en' = ?", en_value).first
  return record if record

  record = klass.new
  record.send(:"#{column}_en=", en_value)
  yield record if block_given?
  record.save!
  record
end

# 1. Create admin user
admin = User.find_or_create_by!(email: "admin@newsportal.com") do |u|
  u.username = "admin"
  u.first_name = "Admin"
  u.last_name = "User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
  u.active = true
end
puts "  Admin: #{admin.email} / password123"

# 2. Create editor
editor = User.find_or_create_by!(email: "editor@newsportal.com") do |u|
  u.username = "editor"
  u.first_name = "Sarah"
  u.last_name = "Editor"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :editor
  u.active = true
end
puts "  Editor: #{editor.email}"

# 3. Create authors
authors = 3.times.map do |i|
  User.find_or_create_by!(email: "author#{i + 1}@newsportal.com") do |u|
    u.username = "author#{i + 1}"
    u.first_name = Faker::Name.first_name
    u.last_name = Faker::Name.last_name
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = :author
    u.active = true
  end
end
puts "  Created #{authors.size} authors"

# 4. Create reader users
5.times do |i|
  User.find_or_create_by!(email: "reader#{i + 1}@newsportal.com") do |u|
    u.username = "reader#{i + 1}"
    u.first_name = Faker::Name.first_name
    u.last_name = Faker::Name.last_name
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = :reader
    u.active = true
  end
end
puts "  Created 5 readers"

# 5. Create categories with hierarchy (English + Bangla names)
categories_data = {
  "Politics" => { bn: "রাজনীতি", children: {
    "National" => "জাতীয়", "International" => "আন্তর্জাতিক", "Elections" => "নির্বাচন"
  } },
  "Technology" => { bn: "প্রযুক্তি", children: {
    "AI & Machine Learning" => "এআই ও মেশিন লার্নিং", "Startups" => "স্টার্টআপ", "Gadgets" => "গ্যাজেট"
  } },
  "Business" => { bn: "ব্যবসা", children: {
    "Markets" => "বাজার", "Economy" => "অর্থনীতি", "Companies" => "কোম্পানি"
  } },
  "Sports" => { bn: "খেলাধুলা", children: {
    "Football" => "ফুটবল", "Basketball" => "বাস্কেটবল", "Tennis" => "টেনিস"
  } },
  "Health" => { bn: "স্বাস্থ্য", children: {
    "Wellness" => "সুস্থতা", "Medical Research" => "চিকিৎসা গবেষণা", "Nutrition" => "পুষ্টি"
  } },
  "Entertainment" => { bn: "বিনোদন", children: {
    "Movies" => "চলচ্চিত্র", "Music" => "সঙ্গীত", "Television" => "টেলিভিশন"
  } },
  "Science" => { bn: "বিজ্ঞান", children: {
    "Space" => "মহাকাশ", "Environment" => "পরিবেশ", "Innovation" => "উদ্ভাবন"
  } },
  "Opinion" => { bn: "মতামত", children: {
    "Editorials" => "সম্পাদকীয়", "Letters" => "চিঠিপত্র", "Columnists" => "কলামিস্ট"
  } }
}

all_categories = []
categories_data.each_with_index do |(parent_name, data), idx|
  parent = find_or_create_translated!(Category, :name, parent_name) do |c|
    c.name_bn = data[:bn]
    c.description_en = Faker::Lorem.sentence(word_count: 10)
    c.position = idx
    c.active = true
  end
  all_categories << parent

  data[:children].each_with_index do |(child_en, child_bn), cidx|
    child = find_or_create_translated!(Category, :name, child_en) do |c|
      c.name_bn = child_bn
      c.description_en = Faker::Lorem.sentence(word_count: 8)
      c.parent = parent
      c.position = cidx
      c.active = true
    end
    all_categories << child
  end
end
puts "  Created #{all_categories.size} categories"

# 6. Create tags (English + Bangla)
tag_translations = {
  "breaking" => "ব্রেকিং", "exclusive" => "এক্সক্লুসিভ", "analysis" => "বিশ্লেষণ",
  "investigation" => "তদন্ত", "feature" => "ফিচার", "interview" => "সাক্ষাৎকার",
  "editorial" => "সম্পাদকীয়", "trending" => "ট্রেন্ডিং", "viral" => "ভাইরাল",
  "controversial" => "বিতর্কিত", "climate" => "জলবায়ু", "cryptocurrency" => "ক্রিপ্টোকারেন্সি",
  "pandemic" => "মহামারি", "elections" => "নির্বাচন", "ai" => "এআই", "space" => "মহাকাশ"
}

tags = tag_translations.map do |en_name, bn_name|
  find_or_create_translated!(Tag, :name, en_name) do |t|
    t.name_bn = bn_name
  end
end
puts "  Created #{tags.size} tags"

# 7. Create articles
staff = [ admin, editor ] + authors
60.times do |i|
  title_en = "#{Faker::Lorem.sentence(word_count: rand(6..10)).chomp('.')} ##{i + 1}"

  article = find_or_create_translated!(Article, :title, title_en) do |a|
    a.excerpt_en = Faker::Lorem.paragraph(sentence_count: 2)
    a.category = all_categories.sample
    a.author = staff.sample
    a.status = [ :draft, :published, :published, :published, :published ].sample
    a.published_at = a.published? ? Faker::Time.between(from: 30.days.ago, to: Time.current) : nil
    a.featured = [ true, false, false, false ].sample
    a.breaking = [ true, false, false, false, false, false ].sample
    a.views_count = rand(0..5000)
    a.comments_enabled = true
    a.meta_title_en = a.title_en
    a.meta_description_en = a.excerpt_en
    a.body_en = Faker::Lorem.paragraphs(number: rand(5..12)).map { |p| "<p>#{p}</p>" }.join
  end
  article.tags = tags.sample(rand(1..4)) if article.article_tags.empty?
end
puts "  Created #{Article.count} articles"

# 8. Create comments
readers = User.where(role: :reader).to_a
Article.published.limit(30).each do |article|
  next if article.comments.any?

  rand(1..5).times do
    comment = article.comments.create!(
      body: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
      user: (readers + staff).sample,
      status: [ :pending, :approved, :approved, :approved ].sample,
      ip_address: Faker::Internet.ip_v4_address
    )

    # Add a reply sometimes
    if [ true, false ].sample
      article.comments.create!(
        body: Faker::Lorem.paragraph(sentence_count: rand(1..2)),
        user: staff.sample,
        parent: comment,
        status: :approved,
        ip_address: Faker::Internet.ip_v4_address
      )
    end
  end
end
puts "  Created #{Comment.count} comments"

# 9. Create static pages (English + Bangla)
pages_data = [
  { en: "About Us", bn: "আমাদের সম্পর্কে", nav: true, pos: 0,
    content_en: "<h2>Our Mission</h2><p>#{Faker::Lorem.paragraphs(number: 3).join('</p><p>')}</p>",
    content_bn: "<h2>আমাদের লক্ষ্য</h2><p>আমরা সত্য ও নিরপেক্ষ সংবাদ পরিবেশনে প্রতিশ্রুতিবদ্ধ।</p>" },
  { en: "Contact", bn: "যোগাযোগ", nav: true, pos: 1,
    content_en: "<p>Email us at contact@newsportal.com</p><p>#{Faker::Lorem.paragraphs(number: 2).join('</p><p>')}</p>",
    content_bn: "<p>ইমেইল: contact@newsportal.com</p><p>আমাদের সাথে যোগাযোগ করুন।</p>" },
  { en: "Privacy Policy", bn: "গোপনীয়তা নীতি", nav: true, pos: 2,
    content_en: "<p>#{Faker::Lorem.paragraphs(number: 5).join('</p><p>')}</p>",
    content_bn: "<p>আপনার গোপনীয়তা আমাদের কাছে গুরুত্বপূর্ণ।</p>" },
  { en: "Terms of Service", bn: "সেবার শর্তাবলী", nav: true, pos: 3,
    content_en: "<p>#{Faker::Lorem.paragraphs(number: 5).join('</p><p>')}</p>",
    content_bn: "<p>এই ওয়েবসাইট ব্যবহার করে আপনি নিম্নলিখিত শর্তাবলী মেনে চলতে সম্মত হচ্ছেন।</p>" }
]

pages_data.each do |pd|
  find_or_create_translated!(Page, :title, pd[:en]) do |p|
    p.title_bn = pd[:bn]
    p.status = :published
    p.show_in_navigation = pd[:nav]
    p.position = pd[:pos]
    p.author = admin
    p.body_en = pd[:content_en]
    p.body_bn = pd[:content_bn]
  end
end
puts "  Created #{Page.count} pages"

# 10. Create sample advertisements
ad_placements = {
  top_banner: {
    title_en: "Premium News Subscription",
    title_bn: "প্রিমিয়াম নিউজ সাবস্ক্রিপশন",
    description_en: "Get unlimited access to all articles. Subscribe today!",
    description_bn: "সব নিবন্ধে সীমাহীন অ্যাক্সেস পান। আজই সাবস্ক্রাইব করুন!",
    target_url: "https://example.com/subscribe"
  },
  sidebar: {
    title_en: "Tech Conference 2026",
    title_bn: "টেক কনফারেন্স ২০২৬",
    description_en: "Join the biggest tech event of the year. Register now!",
    description_bn: "বছরের সবচেয়ে বড় টেক ইভেন্টে যোগ দিন।",
    target_url: "https://example.com/techconf"
  },
  in_feed: {
    title_en: "Learn to Code in 30 Days",
    title_bn: "৩০ দিনে কোডিং শিখুন",
    description_en: "Start your journey to becoming a developer. Free trial available.",
    description_bn: "ডেভেলপার হওয়ার যাত্রা শুরু করুন। বিনামূল্যে ট্রায়াল পাওয়া যায়।",
    target_url: "https://example.com/learn-code"
  },
  popup: {
    title_en: "Breaking News Alerts",
    title_bn: "ব্রেকিং নিউজ অ্যালার্ট",
    description_en: "Never miss important news. Enable push notifications!",
    description_bn: "গুরুত্বপূর্ণ খবর মিস করবেন না। পুশ নোটিফিকেশন চালু করুন!",
    target_url: "https://example.com/alerts"
  }
}

ad_placements.each_with_index do |(placement, data), idx|
  Advertisement.find_or_create_by!(
    title: { "en" => data[:title_en] }
  ) do |a|
    a.title_en = data[:title_en]
    a.title_bn = data[:title_bn]
    a.description_en = data[:description_en]
    a.description_bn = data[:description_bn]
    a.ad_type = :image
    a.placement = placement
    a.position = idx
    a.target_url = data[:target_url]
    a.status = :active
    a.starts_at = 7.days.ago
    a.ends_at = 60.days.from_now
    a.impressions_count = rand(500..5000)
    a.clicks_count = rand(10..200)
  end
end

# Add one HTML embed ad as example
Advertisement.find_or_create_by!(title: { "en" => "Google Ads Partner" }) do |a|
  a.title_en = "Google Ads Partner"
  a.title_bn = "গুগল অ্যাডস পার্টনার"
  a.ad_type = :html
  a.placement = :sidebar
  a.position = 1
  a.embed_code = "<div style='padding:20px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;text-align:center;'><p style='color:#6b7280;font-size:14px;'>Ad placeholder — replace with your ad network code</p></div>"
  a.status = :active
  a.starts_at = 3.days.ago
  a.ends_at = 90.days.from_now
  a.impressions_count = rand(100..1000)
  a.clicks_count = rand(5..50)
end
puts "  Created #{Advertisement.count} advertisements"

puts ""
puts "Seeding complete!"
puts "Login: admin@newsportal.com / password123"
