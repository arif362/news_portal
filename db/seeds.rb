require "faker"
require "open-uri"

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

# Helper: attach image from picsum.photos
def attach_image(record, attachment_name, picsum_id, width: 1200, height: 630)
  return if record.send(attachment_name).attached?

  url = "https://picsum.photos/id/#{picsum_id}/#{width}/#{height}"
  io = URI.open(url)
  record.send(attachment_name).attach(
    io: io,
    filename: "#{record.class.name.underscore}_#{record.id}_#{attachment_name}.jpg",
    content_type: "image/jpeg"
  )
  puts "    Attached image ##{picsum_id} to #{record.class.name} ##{record.id}"
rescue OpenURI::HTTPError, SocketError => e
  puts "    [WARN] Could not attach image ##{picsum_id}: #{e.message}"
end

# 1. Create admin user
admin = User.find_or_create_by!(email: "admin@newstime.com") do |u|
  u.username = "admin"
  u.first_name = "Admin"
  u.last_name = "User"
  u.first_name_bn = "অ্যাডমিন"
  u.last_name_bn = "ইউজার"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
  u.active = true
end
puts "  Admin: #{admin.email} / password123"

# 2. Create editor
editor = User.find_or_create_by!(email: "editor@newstime.com") do |u|
  u.username = "editor"
  u.first_name = "Sarah"
  u.last_name = "Editor"
  u.first_name_bn = "সারাহ"
  u.last_name_bn = "সম্পাদক"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :editor
  u.active = true
end
puts "  Editor: #{editor.email}"

# 3. Create authors
bangla_first_names = [ "রহিম", "করিম", "ফারহানা" ]
bangla_last_names = [ "আহমেদ", "হাসান", "খান" ]
authors = 3.times.map do |i|
  User.find_or_create_by!(email: "author#{i + 1}@newstime.com") do |u|
    u.username = "author#{i + 1}"
    u.first_name = Faker::Name.first_name
    u.last_name = Faker::Name.last_name
    u.first_name_bn = bangla_first_names[i]
    u.last_name_bn = bangla_last_names[i]
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = :author
    u.active = true
  end
end
puts "  Created #{authors.size} authors"

# 4. Create reader users
bangla_reader_first = [ "মাহমুদ", "নাজমুল", "সাদিয়া", "আয়েশা", "রাহেলা" ]
bangla_reader_last = [ "ইসলাম", "হক", "রহমান", "বেগম", "খাতুন" ]
5.times do |i|
  User.find_or_create_by!(email: "reader#{i + 1}@newstime.com") do |u|
    u.username = "reader#{i + 1}"
    u.first_name = Faker::Name.first_name
    u.last_name = Faker::Name.last_name
    u.first_name_bn = bangla_reader_first[i]
    u.last_name_bn = bangla_reader_last[i]
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = :reader
    u.active = true
  end
end
puts "  Created 5 readers"

# 5. Create categories with hierarchy and realistic bilingual descriptions
categories_data = {
  "Politics" => {
    bn: "রাজনীতি",
    desc_en: "Coverage of government policies, diplomatic relations, and political developments shaping nations worldwide.",
    desc_bn: "সরকারি নীতি, কূটনৈতিক সম্পর্ক এবং বিশ্বব্যাপী জাতিগুলিকে রূপদানকারী রাজনৈতিক উন্নয়নের কভারেজ।",
    children: {
      "National" => { bn: "জাতীয়", desc_en: "Domestic political news, parliamentary proceedings, and national policy updates.", desc_bn: "দেশীয় রাজনৈতিক সংবাদ, সংসদীয় কার্যক্রম এবং জাতীয় নীতি আপডেট।" },
      "International" => { bn: "আন্তর্জাতিক", desc_en: "Global diplomatic affairs, foreign policy shifts, and international political events.", desc_bn: "বৈশ্বিক কূটনৈতিক বিষয়, বৈদেশিক নীতি পরিবর্তন এবং আন্তর্জাতিক রাজনৈতিক ঘটনা।" },
      "Elections" => { bn: "নির্বাচন", desc_en: "Election coverage, campaign analysis, voting results, and democratic processes.", desc_bn: "নির্বাচনী কভারেজ, প্রচারণা বিশ্লেষণ, ভোটের ফলাফল এবং গণতান্ত্রিক প্রক্রিয়া।" }
    }
  },
  "Technology" => {
    bn: "প্রযুক্তি",
    desc_en: "Latest innovations in software, hardware, and digital transformation reshaping how we live and work.",
    desc_bn: "সফটওয়্যার, হার্ডওয়্যার এবং ডিজিটাল রূপান্তরের সর্বশেষ উদ্ভাবন যা আমাদের জীবন ও কাজকে নতুন রূপ দিচ্ছে।",
    children: {
      "AI & Machine Learning" => { bn: "কৃত্রিম বুদ্ধিমত্তা ও যন্ত্র শিক্ষা", desc_en: "Artificial intelligence breakthroughs, deep learning research, and AI applications in industry.", desc_bn: "কৃত্রিম বুদ্ধিমত্তার অগ্রগতি, গভীর শিক্ষা গবেষণা এবং শিল্পে কৃত্রিম বুদ্ধিমত্তার প্রয়োগ।" },
      "Startups" => { bn: "নবউদ্যোগ", desc_en: "Emerging tech companies, venture capital funding rounds, and entrepreneurship stories.", desc_bn: "উদীয়মান প্রযুক্তি প্রতিষ্ঠান, উদ্যোগ মূলধন তহবিল এবং উদ্যোক্তাদের গল্প।" },
      "Gadgets" => { bn: "প্রযুক্তি সরঞ্জাম", desc_en: "Reviews and launches of smartphones, laptops, wearables, and consumer electronics.", desc_bn: "স্মার্টফোন, ল্যাপটপ, পরিধানযোগ্য যন্ত্র এবং ভোক্তা ইলেকট্রনিক্সের পর্যালোচনা ও উন্মোচন।" }
    }
  },
  "Business" => {
    bn: "ব্যবসা",
    desc_en: "Financial markets, corporate strategies, economic trends, and the forces driving global commerce.",
    desc_bn: "আর্থিক বাজার, কর্পোরেট কৌশল, অর্থনৈতিক প্রবণতা এবং বৈশ্বিক বাণিজ্য চালিকাশক্তি।",
    children: {
      "Markets" => { bn: "পুঁজিবাজার", desc_en: "Stock exchanges, commodity prices, cryptocurrency markets, and investment analysis.", desc_bn: "শেয়ার বাজার, পণ্য মূল্য, ক্রিপ্টোকারেন্সি বাজার এবং বিনিয়োগ বিশ্লেষণ।" },
      "Economy" => { bn: "অর্থনীতি", desc_en: "GDP growth, inflation reports, monetary policy, and macroeconomic indicators.", desc_bn: "জিডিপি প্রবৃদ্ধি, মুদ্রাস্ফীতি প্রতিবেদন, মুদ্রানীতি এবং সামষ্টিক অর্থনৈতিক সূচক।" },
      "Companies" => { bn: "প্রতিষ্ঠান", desc_en: "Corporate earnings, mergers and acquisitions, leadership changes, and industry news.", desc_bn: "প্রাতিষ্ঠানিক আয়, একীভূতকরণ ও অধিগ্রহণ, নেতৃত্ব পরিবর্তন এবং শিল্প সংবাদ।" }
    }
  },
  "Sports" => {
    bn: "খেলাধুলা",
    desc_en: "Scores, highlights, athlete profiles, and in-depth analysis of sporting events from around the world.",
    desc_bn: "বিশ্বজুড়ে ক্রীড়া ইভেন্টের স্কোর, হাইলাইট, খেলোয়াড়দের প্রোফাইল এবং গভীর বিশ্লেষণ।",
    children: {
      "Football" => { bn: "ফুটবল", desc_en: "Premier League, Champions League, World Cup qualifiers, and transfer news.", desc_bn: "প্রিমিয়ার লিগ, চ্যাম্পিয়ন্স লিগ, বিশ্বকাপ বাছাইপর্ব এবং খেলোয়াড় হস্তান্তর সংবাদ।" },
      "Basketball" => { bn: "ঝুড়ি বল", desc_en: "NBA season updates, playoff coverage, draft picks, and player trades.", desc_bn: "এনবিএ মৌসুম হালনাগাদ, বাছাইপর্ব সংবাদ, নতুন খেলোয়াড় বাছাই এবং খেলোয়াড় বিনিময়।" },
      "Tennis" => { bn: "লন টেনিস", desc_en: "Grand Slam tournaments, ATP and WTA rankings, and match highlights.", desc_bn: "গ্র্যান্ড স্ল্যাম প্রতিযোগিতা, এটিপি ও ডব্লিউটিএ র‍্যাঙ্কিং এবং ম্যাচের সেরা মুহূর্ত।" }
    }
  },
  "Health" => {
    bn: "স্বাস্থ্য",
    desc_en: "Medical breakthroughs, public health initiatives, wellness tips, and healthcare policy updates.",
    desc_bn: "চিকিৎসা অগ্রগতি, জনস্বাস্থ্য উদ্যোগ, সুস্থতার পরামর্শ এবং স্বাস্থ্যসেবা নীতি আপডেট।",
    children: {
      "Wellness" => { bn: "সুস্থতা ও জীবনযাত্রা", desc_en: "Mental health, fitness routines, stress management, and holistic well-being.", desc_bn: "মানসিক স্বাস্থ্য, শরীরচর্চা, মানসিক চাপ ব্যবস্থাপনা এবং সামগ্রিক সুস্থতা।" },
      "Medical Research" => { bn: "চিকিৎসা গবেষণা", desc_en: "Clinical trials, drug discoveries, vaccine development, and peer-reviewed studies.", desc_bn: "পরীক্ষামূলক চিকিৎসা, ওষুধ আবিষ্কার, টিকা উন্নয়ন এবং গবেষণা প্রবন্ধ।" },
      "Nutrition" => { bn: "পুষ্টি ও খাদ্য", desc_en: "Dietary science, superfoods, meal planning, and nutritional guidelines.", desc_bn: "খাদ্য বিজ্ঞান, পুষ্টিকর খাবার, খাদ্য পরিকল্পনা এবং পুষ্টি নির্দেশিকা।" }
    }
  },
  "Entertainment" => {
    bn: "বিনোদন",
    desc_en: "Celebrity news, film and music reviews, streaming platform updates, and pop culture trends.",
    desc_bn: "তারকা সংবাদ, চলচ্চিত্র ও সঙ্গীত পর্যালোচনা, সরাসরি সম্প্রচার মঞ্চের হালনাগাদ এবং জনপ্রিয় সংস্কৃতির প্রবণতা।",
    children: {
      "Movies" => { bn: "চলচ্চিত্র", desc_en: "Box office reports, film reviews, upcoming releases, and award season coverage.", desc_bn: "বক্স অফিস প্রতিবেদন, চলচ্চিত্র পর্যালোচনা, আসন্ন মুক্তি এবং পুরস্কার মৌসুমের সংবাদ।" },
      "Music" => { bn: "সঙ্গীত", desc_en: "Album releases, concert tours, artist interviews, and music industry trends.", desc_bn: "গানের সংকলন প্রকাশ, সঙ্গীত সফর, শিল্পী সাক্ষাৎকার এবং সঙ্গীত শিল্পের প্রবণতা।" },
      "Television" => { bn: "দূরদর্শন ও ধারাবাহিক", desc_en: "Series premieres, streaming originals, TV ratings, and binge-worthy recommendations.", desc_bn: "নতুন ধারাবাহিক, মৌলিক অনুষ্ঠান, দর্শক রেটিং এবং দেখার যোগ্য সুপারিশ।" }
    }
  },
  "Science" => {
    bn: "বিজ্ঞান",
    desc_en: "Discoveries in physics, biology, chemistry, and earth sciences pushing the boundaries of human knowledge.",
    desc_bn: "পদার্থবিদ্যা, জীববিজ্ঞান, রসায়ন এবং ভূবিজ্ঞানে আবিষ্কার যা মানব জ্ঞানের সীমানা প্রসারিত করছে।",
    children: {
      "Space" => { bn: "মহাকাশ", desc_en: "NASA missions, SpaceX launches, exoplanet discoveries, and cosmic phenomena.", desc_bn: "নাসার মিশন, স্পেসএক্স উৎক্ষেপণ, এক্সোপ্ল্যানেট আবিষ্কার এবং মহাজাগতিক ঘটনা।" },
      "Environment" => { bn: "পরিবেশ", desc_en: "Climate change research, conservation efforts, renewable energy, and environmental policy.", desc_bn: "জলবায়ু পরিবর্তন গবেষণা, সংরক্ষণ প্রচেষ্টা, নবায়নযোগ্য শক্তি এবং পরিবেশ নীতি।" },
      "Innovation" => { bn: "উদ্ভাবন", desc_en: "Scientific inventions, patent breakthroughs, and technologies transforming research.", desc_bn: "বৈজ্ঞানিক আবিষ্কার, পেটেন্ট অগ্রগতি এবং গবেষণা রূপান্তরকারী প্রযুক্তি।" }
    }
  },
  "Opinion" => {
    bn: "মতামত",
    desc_en: "Editorials, guest columns, reader letters, and expert commentary on the issues that matter most.",
    desc_bn: "সম্পাদকীয়, অতিথি কলাম, পাঠকের চিঠি এবং সবচেয়ে গুরুত্বপূর্ণ বিষয়ে বিশেষজ্ঞ মন্তব্য।",
    children: {
      "Editorials" => { bn: "সম্পাদকীয়", desc_en: "Our editorial board's stance on current affairs and pressing societal issues.", desc_bn: "বর্তমান বিষয় এবং জরুরি সামাজিক সমস্যায় আমাদের সম্পাদকীয় পর্ষদের অবস্থান।" },
      "Letters" => { bn: "পাঠকের চিঠি", desc_en: "Readers share their perspectives, feedback, and responses to published stories.", desc_bn: "পাঠকরা তাদের দৃষ্টিভঙ্গি, মতামত এবং প্রকাশিত সংবাদের প্রতিক্রিয়া শেয়ার করেন।" },
      "Columnists" => { bn: "কলাম লেখক", desc_en: "Regular contributors offering deep analysis and thought-provoking perspectives.", desc_bn: "নিয়মিত লেখকদের গভীর বিশ্লেষণ এবং চিন্তা-উদ্দীপক দৃষ্টিভঙ্গি।" }
    }
  }
}

all_categories = []
categories_data.each_with_index do |(parent_name, data), idx|
  parent = find_or_create_translated!(Category, :name, parent_name) do |c|
    c.name_bn = data[:bn]
    c.description_en = data[:desc_en]
    c.description_bn = data[:desc_bn]
    c.position = idx
    c.active = true
  end
  all_categories << parent

  data[:children].each_with_index do |(child_en, child_data), cidx|
    child = find_or_create_translated!(Category, :name, child_en) do |c|
      c.name_bn = child_data[:bn]
      c.description_en = child_data[:desc_en]
      c.description_bn = child_data[:desc_bn]
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

# 7. Create articles with realistic bilingual content and images
staff = [ admin, editor ] + authors
tag_map = tags.index_by { |t| t.name_en }
cat_map = all_categories.index_by { |c| c.name_en }

articles_data = []

# -- Politics articles --
articles_data += [
  {
    title_en: "Government Unveils Five-Year Economic Reform Plan",
    title_bn: "সরকার পাঁচ বছরের অর্থনৈতিক সংস্কার পরিকল্পনা উন্মোচন করেছে",
    excerpt_en: "The cabinet has approved a comprehensive economic reform package aimed at boosting GDP growth and reducing unemployment over the next five years.",
    excerpt_bn: "মন্ত্রিসভা আগামী পাঁচ বছরে জিডিপি প্রবৃদ্ধি বাড়ানো এবং বেকারত্ব কমানোর লক্ষ্যে একটি ব্যাপক অর্থনৈতিক সংস্কার প্যাকেজ অনুমোদন করেছে।",
    body_en: "<p>The government today unveiled an ambitious five-year economic reform plan that promises to overhaul the tax system, modernize infrastructure, and create millions of new jobs. Finance Minister announced the plan during a special parliamentary session attended by lawmakers from all parties.</p><p>Key provisions include reducing corporate tax rates for small businesses, investing heavily in digital infrastructure, and establishing special economic zones in underserved regions. Opposition leaders have expressed cautious optimism while calling for greater transparency in implementation.</p><p>Economists have largely welcomed the plan, noting that it addresses long-standing structural issues in the economy. The International Monetary Fund has also signaled its support, calling the reforms a step in the right direction for sustainable growth.</p>",
    body_bn: "<p>সরকার আজ একটি উচ্চাভিলাষী পাঁচ বছরের অর্থনৈতিক সংস্কার পরিকল্পনা উন্মোচন করেছে যা কর ব্যবস্থার সংস্কার, অবকাঠামো আধুনিকীকরণ এবং লক্ষ লক্ষ নতুন কর্মসংস্থান সৃষ্টির প্রতিশ্রুতি দেয়। অর্থমন্ত্রী একটি বিশেষ সংসদ অধিবেশনে পরিকল্পনাটি ঘোষণা করেন।</p><p>মূল বিধানগুলির মধ্যে রয়েছে ক্ষুদ্র ব্যবসার জন্য কর্পোরেট করের হার হ্রাস, ডিজিটাল অবকাঠামোতে ব্যাপক বিনিয়োগ এবং অনগ্রসর অঞ্চলে বিশেষ অর্থনৈতিক অঞ্চল স্থাপন। বিরোধী নেতারা বাস্তবায়নে অধিক স্বচ্ছতার আহ্বান জানিয়েছেন।</p>",
    category: "National", tags: %w[breaking analysis], image_id: 1031, featured: true, breaking: true
  },
  {
    title_en: "EU and ASEAN Sign Historic Free Trade Agreement",
    title_bn: "ইইউ এবং আসিয়ান ঐতিহাসিক মুক্ত বাণিজ্য চুক্তি স্বাক্ষর করেছে",
    excerpt_en: "After years of negotiations, the European Union and ASEAN have finalized a landmark trade deal expected to reshape global commerce patterns.",
    excerpt_bn: "বছরের পর বছর আলোচনার পর, ইউরোপীয় ইউনিয়ন এবং আসিয়ান একটি যুগান্তকারী বাণিজ্য চুক্তি চূড়ান্ত করেছে যা বৈশ্বিক বাণিজ্যকে নতুন রূপ দেবে বলে আশা করা হচ্ছে।",
    body_en: "<p>In a ceremony held in Brussels, leaders from the European Union and the Association of Southeast Asian Nations signed a comprehensive free trade agreement that will eliminate tariffs on over 90% of goods traded between the two blocs. The deal, which took nearly a decade to negotiate, is the largest bilateral trade agreement by population coverage.</p><p>The agreement includes provisions for digital trade, environmental standards, and labor protections. Trade experts predict it will boost bilateral trade by an estimated $180 billion annually within five years of implementation.</p>",
    body_bn: "<p>ব্রাসেলসে অনুষ্ঠিত একটি অনুষ্ঠানে, ইউরোপীয় ইউনিয়ন এবং দক্ষিণ-পূর্ব এশীয় জাতি সংস্থার নেতারা একটি ব্যাপক মুক্ত বাণিজ্য চুক্তি স্বাক্ষর করেছেন যা দুই ব্লকের মধ্যে ৯০% এরও বেশি পণ্যের শুল্ক বিলুপ্ত করবে।</p><p>চুক্তিতে ডিজিটাল বাণিজ্য, পরিবেশগত মান এবং শ্রম সুরক্ষার বিধান অন্তর্ভুক্ত রয়েছে। বাণিজ্য বিশেষজ্ঞরা অনুমান করছেন এটি বার্ষিক আনুমানিক ১৮০ বিলিয়ন ডলার দ্বিপাক্ষিক বাণিজ্য বৃদ্ধি করবে।</p>",
    category: "International", tags: %w[exclusive analysis], image_id: 901, featured: false
  },
  {
    title_en: "Record Voter Turnout Marks Historic Municipal Elections",
    title_bn: "ঐতিহাসিক পৌরসভা নির্বাচনে রেকর্ড ভোটার উপস্থিতি",
    excerpt_en: "Over 78% of eligible voters participated in this year's municipal elections, the highest turnout recorded in the country's democratic history.",
    excerpt_bn: "এই বছরের পৌরসভা নির্বাচনে ৭৮% এরও বেশি যোগ্য ভোটার অংশগ্রহণ করেছেন, যা দেশের গণতান্ত্রিক ইতিহাসে সর্বোচ্চ উপস্থিতি।",
    body_en: "<p>Municipal elections across the country concluded yesterday with an unprecedented voter turnout of 78.3%, shattering the previous record of 71% set twelve years ago. Election officials attributed the surge to new online voter registration systems and extended polling hours in rural districts.</p><p>The elections saw a significant shift in urban demographics, with younger voters aged 18-25 participating at nearly double the rate of previous elections. Political analysts say this generational shift could reshape municipal governance priorities in the years ahead.</p>",
    body_bn: "<p>সারাদেশে পৌরসভা নির্বাচন গতকাল ৭৮.৩% ভোটার উপস্থিতির মধ্য দিয়ে সমাপ্ত হয়েছে, যা বারো বছর আগের ৭১% রেকর্ড ভেঙে দিয়েছে। নির্বাচন কর্মকর্তারা এই বৃদ্ধির কারণ হিসেবে নতুন অনলাইন ভোটার নিবন্ধন ব্যবস্থা এবং গ্রামীণ এলাকায় ভোটের সময় বাড়ানোকে উল্লেখ করেছেন।</p>",
    category: "Elections", tags: %w[breaking elections], image_id: 433, featured: true
  },
  {
    title_en: "Parliament Passes Landmark Digital Privacy Legislation",
    title_bn: "সংসদ যুগান্তকারী ডিজিটাল গোপনীয়তা আইন পাস করেছে",
    excerpt_en: "New data protection law gives citizens unprecedented control over personal data held by corporations and government agencies.",
    excerpt_bn: "নতুন তথ্য সুরক্ষা আইন নাগরিকদের কর্পোরেশন এবং সরকারি সংস্থাগুলির কাছে রাখা ব্যক্তিগত তথ্যের উপর অভূতপূর্ব নিয়ন্ত্রণ দেয়।",
    body_en: "<p>Parliament has passed the Digital Privacy Protection Act with an overwhelming bipartisan majority of 312 to 45. The legislation, which will take effect in six months, requires all organizations to obtain explicit consent before collecting personal data and grants citizens the right to request complete deletion of their digital footprint.</p><p>The law establishes a new Digital Privacy Commission with enforcement powers including fines of up to 4% of annual global revenue for non-compliant organizations. Privacy advocates have called it the most comprehensive data protection framework in the region.</p>",
    body_bn: "<p>সংসদ ৩১২-৪৫ এর অপ্রতিরোধ্য দ্বিদলীয় সংখ্যাগরিষ্ঠতায় ডিজিটাল গোপনীয়তা সুরক্ষা আইন পাস করেছে। আইনটি ছয় মাসের মধ্যে কার্যকর হবে এবং সমস্ত সংস্থাকে ব্যক্তিগত তথ্য সংগ্রহের আগে স্পষ্ট সম্মতি নিতে হবে।</p>",
    category: "National", tags: %w[breaking trending], image_id: 180, featured: false
  }
]

# -- Technology articles --
articles_data += [
  {
    title_en: "OpenAI Launches GPT-6 with Breakthrough Reasoning Capabilities",
    title_bn: "ওপেনএআই যুগান্তকারী যুক্তি ক্ষমতাসহ জিপিটি-৬ চালু করেছে",
    excerpt_en: "The latest language model demonstrates near-human reasoning in complex scientific and mathematical problems, marking a new milestone in AI development.",
    excerpt_bn: "সর্বশেষ ভাষা মডেলটি জটিল বৈজ্ঞানিক ও গাণিতিক সমস্যায় মানুষের কাছাকাছি যুক্তি প্রদর্শন করে, এআই উন্নয়নে একটি নতুন মাইলফলক।",
    body_en: "<p>OpenAI has released GPT-6, its most advanced artificial intelligence model to date, showcasing reasoning abilities that researchers say approach human-level performance on complex tasks. The model demonstrated 94% accuracy on graduate-level science examinations and solved previously unsolved mathematical proofs during testing.</p><p>The release has sparked both excitement and concern in the AI community. Leading researchers praised the technical achievement while calling for stronger governance frameworks. The model will initially be available through a controlled API access program before broader public release.</p>",
    body_bn: "<p>ওপেনএআই তাদের সর্বাধিক উন্নত কৃত্রিম বুদ্ধিমত্তা মডেল জিপিটি-৬ প্রকাশ করেছে, যা গবেষকরা বলছেন জটিল কাজে মানব-স্তরের কর্মক্ষমতার কাছাকাছি যুক্তি ক্ষমতা প্রদর্শন করে। মডেলটি স্নাতক-স্তরের বিজ্ঞান পরীক্ষায় ৯৪% নির্ভুলতা প্রদর্শন করেছে।</p>",
    category: "AI & Machine Learning", tags: %w[trending ai exclusive], image_id: 0, featured: true, breaking: true
  },
  {
    title_en: "Dhaka-Based Fintech Startup Raises $120 Million in Series C Funding",
    title_bn: "ঢাকাভিত্তিক ফিনটেক স্টার্টআপ সিরিজ সি ফান্ডিংয়ে ১২০ মিলিয়ন ডলার সংগ্রহ করেছে",
    excerpt_en: "PayBangla has become the country's first unicorn after securing major investment from SoftBank Vision Fund and Sequoia Capital.",
    excerpt_bn: "সফটব্যাংক ভিশন ফান্ড এবং সিকোইয়া ক্যাপিটালের বড় বিনিয়োগ নিশ্চিত করার পর পেবাংলা দেশের প্রথম ইউনিকর্ন হয়ে উঠেছে।",
    body_en: "<p>PayBangla, a mobile payments platform founded in Dhaka just four years ago, has raised $120 million in Series C funding led by SoftBank Vision Fund, with participation from Sequoia Capital and existing investors. The round values the company at $1.2 billion, making it the country's first technology unicorn.</p><p>The company processes over 5 million transactions daily across South Asia and plans to use the new funding to expand into three additional markets and launch a micro-lending service targeting small merchants in rural areas.</p>",
    body_bn: "<p>মাত্র চার বছর আগে ঢাকায় প্রতিষ্ঠিত মোবাইল পেমেন্ট প্ল্যাটফর্ম পেবাংলা সফটব্যাংক ভিশন ফান্ডের নেতৃত্বে সিরিজ সি ফান্ডিংয়ে ১২০ মিলিয়ন ডলার সংগ্রহ করেছে। এই রাউন্ড কোম্পানিকে ১.২ বিলিয়ন ডলারে মূল্যায়ন করেছে, যা দেশের প্রথম প্রযুক্তি ইউনিকর্ন।</p>",
    category: "Startups", tags: %w[exclusive trending], image_id: 1067, featured: false
  },
  {
    title_en: "Samsung Unveils Foldable Laptop with Holographic Display",
    title_bn: "স্যামসাং হলোগ্রাফিক ডিসপ্লেসহ ভাঁজযোগ্য ল্যাপটপ উন্মোচন করেছে",
    excerpt_en: "The Galaxy Book Fold features a transparent OLED screen that projects 3D holographic images, redefining the future of portable computing.",
    excerpt_bn: "গ্যালাক্সি বুক ফোল্ড একটি স্বচ্ছ ওএলইডি স্ক্রিন বৈশিষ্ট্যযুক্ত যা থ্রিডি হলোগ্রাফিক ইমেজ প্রজেক্ট করে।",
    body_en: "<p>Samsung has unveiled the Galaxy Book Fold at its annual Unpacked event, featuring the world's first consumer-grade holographic display integrated into a foldable laptop form factor. The device uses micro-LED projectors embedded in the screen bezel to create floating 3D images above the display surface.</p><p>Priced at $2,499, the device will ship in March and targets creative professionals. Industry analysts expect the technology to eventually trickle down to mainstream laptops within two to three years as manufacturing costs decrease.</p>",
    body_bn: "<p>স্যামসাং তার বার্ষিক আনপ্যাকড ইভেন্টে গ্যালাক্সি বুক ফোল্ড উন্মোচন করেছে, যেটিতে বিশ্বের প্রথম ভোক্তা-গ্রেড হলোগ্রাফিক ডিসপ্লে রয়েছে। ডিভাইসটি $২,৪৯৯ মূল্যে মার্চ মাসে বাজারে আসবে।</p>",
    category: "Gadgets", tags: %w[trending feature], image_id: 119, featured: false
  },
  {
    title_en: "Google DeepMind AI Discovers New Antibiotic Compound",
    title_bn: "গুগল ডিপমাইন্ড এআই নতুন অ্যান্টিবায়োটিক যৌগ আবিষ্কার করেছে",
    excerpt_en: "Machine learning algorithms have identified a novel antibiotic effective against drug-resistant superbugs, potentially saving millions of lives.",
    excerpt_bn: "মেশিন লার্নিং অ্যালগরিদম ওষুধ-প্রতিরোধী সুপারবাগের বিরুদ্ধে কার্যকর একটি নতুন অ্যান্টিবায়োটিক শনাক্ত করেছে।",
    body_en: "<p>Google DeepMind's AlphaFold drug discovery platform has identified a completely new class of antibiotic compounds that show remarkable effectiveness against methicillin-resistant Staphylococcus aureus and other drug-resistant bacteria. The AI screened over 100 million molecular structures in just three days.</p><p>Clinical trials are expected to begin within 18 months. The World Health Organization has described the discovery as potentially the most significant advancement in antibiotic research in over four decades, offering hope in the fight against antimicrobial resistance.</p>",
    body_bn: "<p>গুগল ডিপমাইন্ডের আলফাফোল্ড ড্রাগ ডিসকভারি প্ল্যাটফর্ম সম্পূর্ণ নতুন শ্রেণির অ্যান্টিবায়োটিক যৌগ শনাক্ত করেছে যা ওষুধ-প্রতিরোধী ব্যাকটেরিয়ার বিরুদ্ধে অসাধারণ কার্যকারিতা দেখায়। ক্লিনিক্যাল ট্রায়াল ১৮ মাসের মধ্যে শুরু হবে বলে আশা করা হচ্ছে।</p>",
    category: "AI & Machine Learning", tags: %w[breaking ai feature], image_id: 250, featured: true
  }
]

# -- Business articles --
articles_data += [
  {
    title_en: "Global Stock Markets Rally as Inflation Fears Ease",
    title_bn: "মুদ্রাস্ফীতি ভীতি কমায় বৈশ্বিক শেয়ার বাজারে ঊর্ধ্বগতি",
    excerpt_en: "Major indices posted their strongest weekly gains in six months after central banks signaled a pause in interest rate hikes.",
    excerpt_bn: "কেন্দ্রীয় ব্যাংকগুলো সুদের হার বৃদ্ধিতে বিরতির ইঙ্গিত দেওয়ার পর প্রধান সূচকগুলো ছয় মাসের মধ্যে সবচেয়ে শক্তিশালী সাপ্তাহিক অর্জন করেছে।",
    body_en: "<p>Global equity markets surged on Friday, capping off the strongest week of gains since August, as investors reacted positively to signals from the Federal Reserve and European Central Bank that interest rate hikes may be approaching their end. The S&P 500 rose 2.3%, while European and Asian markets posted similar gains.</p><p>Consumer price inflation data released this week showed a steady decline across major economies, with the US recording 2.8% annual inflation, down from a peak of 6.1% eighteen months ago. Bond yields fell sharply as traders priced in potential rate cuts in the second half of the year.</p>",
    body_bn: "<p>বিনিয়োগকারীরা ফেডারেল রিজার্ভ এবং ইউরোপীয় কেন্দ্রীয় ব্যাংকের সুদের হার বৃদ্ধির সমাপ্তির ইঙ্গিতে ইতিবাচক প্রতিক্রিয়া দেখানোয় শুক্রবার বৈশ্বিক শেয়ার বাজারে ব্যাপক ঊর্ধ্বগতি দেখা গেছে। এসএন্ডপি ৫০০ ২.৩% বেড়েছে।</p>",
    category: "Markets", tags: %w[breaking analysis], image_id: 1005, featured: false
  },
  {
    title_en: "Bangladesh GDP Growth Accelerates to 7.2% in Latest Quarter",
    title_bn: "সর্বশেষ প্রান্তিকে বাংলাদেশের জিডিপি প্রবৃদ্ধি ৭.২% এ ত্বরান্বিত",
    excerpt_en: "Strong garment exports and remittance inflows drive the economy to outperform regional peers for the third consecutive quarter.",
    excerpt_bn: "শক্তিশালী পোশাক রপ্তানি এবং রেমিট্যান্স প্রবাহ পরপর তৃতীয় প্রান্তিকে অর্থনীতিকে আঞ্চলিক প্রতিদ্বন্দ্বীদের ছাড়িয়ে যেতে চালিত করেছে।",
    body_en: "<p>Bangladesh's economy grew at an annualized rate of 7.2% in the October-December quarter, according to data released by the Bureau of Statistics. The growth was primarily driven by a 14% surge in ready-made garment exports and record remittance inflows from overseas workers totaling $6.8 billion for the quarter.</p><p>The technology services sector also contributed significantly, growing 22% year-over-year as the country positions itself as an emerging outsourcing destination. The central bank maintained its projection of 7% growth for the full fiscal year.</p>",
    body_bn: "<p>পরিসংখ্যান ব্যুরোর প্রকাশিত তথ্য অনুযায়ী, অক্টোবর-ডিসেম্বর প্রান্তিকে বাংলাদেশের অর্থনীতি ৭.২% বার্ষিক হারে প্রবৃদ্ধি অর্জন করেছে। তৈরি পোশাক রপ্তানিতে ১৪% বৃদ্ধি এবং প্রবাসী শ্রমিকদের রেকর্ড রেমিট্যান্স প্রবাহ এই প্রবৃদ্ধির প্রধান চালিকাশক্তি।</p>",
    category: "Economy", tags: %w[analysis feature], image_id: 683, featured: true
  },
  {
    title_en: "Tesla Completes Acquisition of Major Lithium Mining Company",
    title_bn: "টেসলা বড় লিথিয়াম খনন কোম্পানির অধিগ্রহণ সম্পন্ন করেছে",
    excerpt_en: "The $4.7 billion deal secures Tesla's battery supply chain and signals a new era of vertical integration in the EV industry.",
    excerpt_bn: "৪.৭ বিলিয়ন ডলারের চুক্তি টেসলার ব্যাটারি সরবরাহ শৃঙ্খল সুরক্ষিত করে এবং ইভি শিল্পে উল্লম্ব একীকরণের নতুন যুগের সংকেত দেয়।",
    body_en: "<p>Tesla has completed its $4.7 billion acquisition of Piedmont Lithium, gaining direct control over one of North America's largest lithium reserves. The deal, first announced three months ago, gives Tesla access to enough raw material to produce approximately 2 million battery packs annually.</p><p>Industry analysts view the acquisition as a strategic move to reduce Tesla's dependence on Chinese lithium processors. Other major automakers are expected to pursue similar vertical integration strategies as competition for battery materials intensifies globally.</p>",
    body_bn: "<p>টেসলা পিডমন্ট লিথিয়ামের ৪.৭ বিলিয়ন ডলারের অধিগ্রহণ সম্পন্ন করেছে, যা উত্তর আমেরিকার বৃহত্তম লিথিয়াম মজুদের উপর সরাসরি নিয়ন্ত্রণ দেয়। শিল্প বিশ্লেষকরা এটিকে চীনা লিথিয়াম প্রসেসরদের উপর নির্ভরতা কমানোর কৌশলগত পদক্ষেপ হিসেবে দেখছেন।</p>",
    category: "Companies", tags: %w[exclusive trending], image_id: 1071, featured: false
  },
  {
    title_en: "Cryptocurrency Market Surpasses $4 Trillion Valuation",
    title_bn: "ক্রিপ্টোকারেন্সি বাজারের মূল্যায়ন ৪ ট্রিলিয়ন ডলার ছাড়িয়েছে",
    excerpt_en: "Bitcoin reaches new all-time high above $125,000 as institutional adoption accelerates and spot ETFs attract record inflows.",
    excerpt_bn: "প্রাতিষ্ঠানিক গ্রহণ ত্বরান্বিত হওয়ায় এবং স্পট ইটিএফ রেকর্ড প্রবাহ আকর্ষণ করায় বিটকয়েন $১২৫,০০০ এর উপরে নতুন সর্বকালের উচ্চতায় পৌঁছেছে।",
    body_en: "<p>The total cryptocurrency market capitalization has surpassed $4 trillion for the first time, driven by Bitcoin's surge above $125,000 and strong gains in Ethereum and Solana. Spot Bitcoin ETFs have accumulated over $80 billion in assets since their approval, with BlackRock's iShares Bitcoin Trust alone holding $35 billion.</p><p>Major corporations including Apple, Amazon, and Samsung have announced plans to accept cryptocurrency payments, further legitimizing digital assets as mainstream financial instruments. Regulatory clarity in the US and EU has also boosted investor confidence.</p>",
    body_bn: "<p>বিটকয়েনের $১২৫,০০০ এর উপরে উত্থান এবং ইথেরিয়াম ও সোলানায় শক্তিশালী অর্জনের মাধ্যমে মোট ক্রিপ্টোকারেন্সি বাজার মূলধন প্রথমবারের মতো ৪ ট্রিলিয়ন ডলার ছাড়িয়েছে। অ্যাপল, অ্যামাজন সহ বড় কর্পোরেশনগুলো ক্রিপ্টোকারেন্সি পেমেন্ট গ্রহণের পরিকল্পনা ঘোষণা করেছে।</p>",
    category: "Markets", tags: %w[trending cryptocurrency], image_id: 1062, featured: false
  }
]

# -- Sports articles --
articles_data += [
  {
    title_en: "Manchester City Clinch Record Fifth Consecutive Premier League Title",
    title_bn: "ম্যানচেস্টার সিটি রেকর্ড পঞ্চম পরপর প্রিমিয়ার লিগ শিরোপা জিতেছে",
    excerpt_en: "Pep Guardiola's side seal an unprecedented fifth straight league championship with three games to spare.",
    excerpt_bn: "পেপ গুয়ার্দিওলার দল তিন ম্যাচ বাকি থাকতে অভূতপূর্ব পঞ্চম পরপর লিগ চ্যাম্পিয়নশিপ নিশ্চিত করেছে।",
    body_en: "<p>Manchester City have secured their fifth consecutive Premier League title after nearest rivals Arsenal dropped points in a goalless draw against Aston Villa. The achievement surpasses the previous record of three consecutive titles held jointly by Manchester United and Huddersfield Town.</p><p>Manager Pep Guardiola described the accomplishment as his greatest achievement in football. Star midfielder Kevin De Bruyne contributed 18 assists this season, while Erling Haaland scored 32 league goals. The club now turns its attention to the Champions League final next month.</p>",
    body_bn: "<p>নিকটতম প্রতিদ্বন্দ্বী আর্সেনাল অ্যাস্টন ভিলার বিরুদ্ধে গোলশূন্য ড্রয়ে পয়েন্ট হারানোর পর ম্যানচেস্টার সিটি তাদের পঞ্চম পরপর প্রিমিয়ার লিগ শিরোপা নিশ্চিত করেছে। ম্যানেজার পেপ গুয়ার্দিওলা এই অর্জনকে ফুটবলে তার সর্বশ্রেষ্ঠ সাফল্য বলে বর্ণনা করেছেন।</p>",
    category: "Football", tags: %w[breaking trending], image_id: 237, featured: true, breaking: true
  },
  {
    title_en: "NBA Finals: Denver Nuggets Defeat Miami Heat in Thrilling Game Seven",
    title_bn: "এনবিএ ফাইনালস: ডেনভার নাগেটস রোমাঞ্চকর সপ্তম গেমে মায়ামি হিটকে পরাজিত করেছে",
    excerpt_en: "Nikola Jokic delivers a historic triple-double as the Nuggets claim their second championship in franchise history.",
    excerpt_bn: "নিকোলা জোকিচ ঐতিহাসিক ট্রিপল-ডাবল প্রদান করায় নাগেটস ফ্র্যাঞ্চাইজ ইতিহাসে তাদের দ্বিতীয় চ্যাম্পিয়নশিপ দাবি করেছে।",
    body_en: "<p>The Denver Nuggets defeated the Miami Heat 104-98 in a dramatic Game Seven to win the NBA Finals. Nikola Jokic recorded 28 points, 16 rebounds, and 12 assists in a masterful triple-double performance that earned him his second Finals MVP award.</p><p>The series, considered one of the greatest in NBA history, featured four overtime games and multiple lead changes in the final minutes. Over 22 million viewers tuned in for Game Seven, making it the most-watched NBA Finals in over a decade.</p>",
    body_bn: "<p>ডেনভার নাগেটস নাটকীয় সপ্তম গেমে মায়ামি হিটকে ১০৪-৯৮ এ পরাজিত করে এনবিএ ফাইনালস জিতেছে। নিকোলা জোকিচ ২৮ পয়েন্ট, ১৬ রিবাউন্ড এবং ১২ অ্যাসিস্টের একটি অসাধারণ ট্রিপল-ডাবল পারফরম্যান্স রেকর্ড করেন।</p>",
    category: "Basketball", tags: %w[breaking exclusive], image_id: 529, featured: true
  },
  {
    title_en: "Djokovic Wins Record 25th Grand Slam Title at Australian Open",
    title_bn: "জকোভিচ অস্ট্রেলিয়ান ওপেনে রেকর্ড ২৫তম গ্র্যান্ড স্ল্যাম শিরোপা জিতেছেন",
    excerpt_en: "The Serbian champion defeats Carlos Alcaraz in a five-set epic to extend his all-time Grand Slam record.",
    excerpt_bn: "সার্বিয়ান চ্যাম্পিয়ন কার্লোস আলকারাজকে পাঁচ সেটের মহাকাব্যিক ম্যাচে পরাজিত করে তার সর্বকালের গ্র্যান্ড স্ল্যাম রেকর্ড বাড়িয়েছেন।",
    body_en: "<p>Novak Djokovic claimed his 25th Grand Slam title with a grueling five-set victory over Carlos Alcaraz at the Australian Open, winning 6-4, 3-6, 6-7, 7-5, 6-2 in a match lasting over four hours. At 38, Djokovic became the oldest Australian Open champion in the Open Era.</p><p>The match drew a record crowd of 15,000 at Rod Laver Arena. In his victory speech, Djokovic hinted this may be his final year on tour, calling it an honor to compete against the next generation of champions.</p>",
    body_bn: "<p>নোভাক জকোভিচ অস্ট্রেলিয়ান ওপেনে কার্লোস আলকারাজের বিরুদ্ধে চার ঘণ্টারও বেশি সময়ের ম্যাচে ৬-৪, ৩-৬, ৬-৭, ৭-৫, ৬-২ তে জয়ী হয়ে তার ২৫তম গ্র্যান্ড স্ল্যাম শিরোপা দাবি করেছেন। ৩৮ বছর বয়সে তিনি ওপেন এরায় সবচেয়ে বয়স্ক অস্ট্রেলিয়ান ওপেন চ্যাম্পিয়ন হয়েছেন।</p>",
    category: "Tennis", tags: %w[breaking exclusive], image_id: 342, featured: false
  },
  {
    title_en: "FIFA Announces Expansion of Club World Cup to 64 Teams",
    title_bn: "ফিফা ক্লাব বিশ্বকাপ ৬৪ দলে সম্প্রসারণের ঘোষণা দিয়েছে",
    excerpt_en: "The expanded tournament format will include clubs from all six confederations and feature a month-long competition starting in 2027.",
    excerpt_bn: "সম্প্রসারিত টুর্নামেন্ট ফরম্যাটে সকল ছয়টি কনফেডারেশনের ক্লাব অন্তর্ভুক্ত থাকবে এবং ২০২৭ সাল থেকে একমাসব্যাপী প্রতিযোগিতা হবে।",
    body_en: "<p>FIFA President Gianni Infantino announced that the Club World Cup will expand from 32 to 64 teams starting with the 2027 edition, to be held in the United States. The tournament will feature 16 teams from Europe, 12 from South America, and representatives from every confederation.</p><p>The expanded format has received a mixed response. European clubs have expressed concern about fixture congestion, while clubs from smaller confederations welcome the increased representation and revenue-sharing opportunities.</p>",
    body_bn: "<p>ফিফা প্রেসিডেন্ট জিয়ান্নি ইনফান্তিনো ঘোষণা করেছেন যে ক্লাব বিশ্বকাপ ২০২৭ সংস্করণ থেকে ৩২ থেকে ৬৪ দলে সম্প্রসারিত হবে, যা যুক্তরাষ্ট্রে অনুষ্ঠিত হবে। টুর্নামেন্টে ইউরোপ থেকে ১৬টি এবং দক্ষিণ আমেরিকা থেকে ১২টি দল থাকবে।</p>",
    category: "Football", tags: %w[exclusive feature], image_id: 462, featured: false
  }
]

# -- Health articles --
articles_data += [
  {
    title_en: "WHO Declares End of Global Mpox Health Emergency",
    title_bn: "বিশ্ব স্বাস্থ্য সংস্থা বৈশ্বিক এমপক্স স্বাস্থ্য জরুরি অবস্থার সমাপ্তি ঘোষণা করেছে",
    excerpt_en: "After 18 months, the World Health Organization lifts its highest alert level as vaccination campaigns successfully contain the outbreak.",
    excerpt_bn: "টিকাদান প্রচারাভিযান সফলভাবে প্রাদুর্ভাব নিয়ন্ত্রণ করায় ১৮ মাস পর বিশ্ব স্বাস্থ্য সংস্থা তার সর্বোচ্চ সতর্কতা স্তর প্রত্যাহার করেছে।",
    body_en: "<p>The World Health Organization has officially declared the end of the global mpox public health emergency, citing a 95% decline in new cases worldwide. The decision comes after coordinated vaccination campaigns across 47 countries successfully brought transmission rates under control.</p><p>WHO Director-General praised the international response as a model for future pandemic preparedness. Over 120 million vaccine doses were administered globally, with the highest coverage rates in Sub-Saharan Africa where the outbreak was most severe.</p>",
    body_bn: "<p>বিশ্বব্যাপী নতুন কেসে ৯৫% হ্রাসের কথা উল্লেখ করে বিশ্ব স্বাস্থ্য সংস্থা আনুষ্ঠানিকভাবে বৈশ্বিক এমপক্স জনস্বাস্থ্য জরুরি অবস্থার সমাপ্তি ঘোষণা করেছে। ৪৭টি দেশে সমন্বিত টিকাদান প্রচারাভিযান সফলভাবে সংক্রমণের হার নিয়ন্ত্রণে এনেছে।</p>",
    category: "Medical Research", tags: %w[breaking pandemic], image_id: 701, featured: true, breaking: true
  },
  {
    title_en: "Mediterranean Diet Linked to 30% Lower Dementia Risk",
    title_bn: "ভূমধ্যসাগরীয় খাদ্যাভ্যাসে ডিমেনশিয়ার ঝুঁকি ৩০% কম",
    excerpt_en: "A 20-year study of 40,000 participants reveals that strict adherence to the Mediterranean diet significantly reduces cognitive decline.",
    excerpt_bn: "৪০,০০০ অংশগ্রহণকারীর উপর ২০ বছরের গবেষণায় দেখা গেছে ভূমধ্যসাগরীয় খাদ্যাভ্যাস জ্ঞানীয় অবক্ষয় উল্লেখযোগ্যভাবে হ্রাস করে।",
    body_en: "<p>Researchers at the University of Barcelona have published findings from one of the largest and longest dietary studies ever conducted, showing that participants who closely followed the Mediterranean diet had a 30% lower risk of developing dementia compared to those on standard Western diets.</p><p>The study tracked 40,000 adults over 20 years across eight European countries. Key protective foods included olive oil, leafy greens, fatty fish, and nuts. Researchers noted that the benefits were most pronounced in participants who maintained the diet consistently for over a decade.</p>",
    body_bn: "<p>বার্সেলোনা বিশ্ববিদ্যালয়ের গবেষকরা এযাবৎকালের বৃহত্তম ও দীর্ঘতম খাদ্যতালিকা গবেষণার ফলাফল প্রকাশ করেছেন, যেখানে দেখা গেছে ভূমধ্যসাগরীয় খাদ্যাভ্যাস অনুসরণকারীদের ডিমেনশিয়ার ঝুঁকি ৩০% কম। গবেষণাটি আটটি ইউরোপীয় দেশে ২০ বছর ধরে ৪০,০০০ প্রাপ্তবয়স্ককে ট্র্যাক করেছে।</p>",
    category: "Nutrition", tags: %w[feature analysis], image_id: 488, featured: false
  },
  {
    title_en: "New Study Reveals Benefits of Daily Cold Water Immersion",
    title_bn: "নতুন গবেষণায় দৈনিক ঠান্ডা পানিতে নিমজ্জনের উপকারিতা প্রকাশ",
    excerpt_en: "Clinical trials show that regular cold water exposure improves immune function, reduces inflammation, and boosts mental health.",
    excerpt_bn: "ক্লিনিক্যাল ট্রায়ালে দেখা গেছে নিয়মিত ঠান্ডা পানির সংস্পর্শ রোগ প্রতিরোধ ক্ষমতা উন্নত করে এবং মানসিক স্বাস্থ্যের উন্নতি করে।",
    body_en: "<p>A comprehensive clinical trial published in the Journal of Clinical Medicine has provided the strongest evidence yet for the health benefits of daily cold water immersion. The study of 3,000 participants found that those who took two-minute cold showers daily for six months showed 29% fewer sick days and reported significantly improved mood scores.</p><p>The research also documented measurable increases in brown fat activation and norepinephrine levels. Health experts caution that the practice may not be suitable for individuals with cardiovascular conditions.</p>",
    body_bn: "<p>জার্নাল অফ ক্লিনিক্যাল মেডিসিনে প্রকাশিত একটি ব্যাপক ক্লিনিক্যাল ট্রায়াল দৈনিক ঠান্ডা পানিতে নিমজ্জনের স্বাস্থ্য উপকারিতার পক্ষে এখন পর্যন্ত সবচেয়ে শক্তিশালী প্রমাণ সরবরাহ করেছে। ৩,০০০ অংশগ্রহণকারীর গবেষণায় দেখা গেছে দৈনিক দুই মিনিটের ঠান্ডা শাওয়ার ২৯% কম অসুস্থ দিন দেখিয়েছে।</p>",
    category: "Wellness", tags: %w[trending feature], image_id: 325, featured: false
  }
]

# -- Entertainment articles --
articles_data += [
  {
    title_en: "Oscars 2026: South Korean Film Wins Best Picture for Second Time",
    title_bn: "অস্কার ২০২৬: দক্ষিণ কোরিয়ান চলচ্চিত্র দ্বিতীয়বার সেরা ছবির পুরস্কার জিতেছে",
    excerpt_en: "Director Park Chan-wook's psychological thriller becomes only the second non-English language film to win the Academy's top honor.",
    excerpt_bn: "পরিচালক পার্ক চান-উকের মনস্তাত্ত্বিক থ্রিলার একাডেমির শীর্ষ সম্মান জিতে মাত্র দ্বিতীয় অ-ইংরেজি ভাষার চলচ্চিত্র হয়ে উঠেছে।",
    body_en: "<p>Park Chan-wook's psychological thriller \"The Mirror's Edge\" won Best Picture at the 98th Academy Awards, making it only the second non-English language film to claim Hollywood's highest honor after Bong Joon-ho's Parasite in 2020. The film also won Best Director and Best Original Screenplay.</p><p>The ceremony drew 35 million viewers, the highest in five years. In his acceptance speech, Park dedicated the award to Korean cinema's tradition of bold storytelling. The film has grossed over $320 million worldwide against a modest $25 million budget.</p>",
    body_bn: "<p>পার্ক চান-উকের মনস্তাত্ত্বিক থ্রিলার \"দ্য মিরর'স এজ\" ৯৮তম একাডেমি পুরস্কারে সেরা ছবির পুরস্কার জিতেছে। চলচ্চিত্রটি সেরা পরিচালক এবং সেরা মৌলিক চিত্রনাট্যের পুরস্কারও জিতেছে। ছবিটি বিশ্বব্যাপী ৩২০ মিলিয়ন ডলারের বেশি আয় করেছে।</p>",
    category: "Movies", tags: %w[trending exclusive], image_id: 436, featured: true
  },
  {
    title_en: "Taylor Swift Breaks Billboard Record with 15th Number-One Album",
    title_bn: "টেইলর সুইফট ১৫তম নম্বর-ওয়ান অ্যালবামের মাধ্যমে বিলবোর্ড রেকর্ড ভেঙেছেন",
    excerpt_en: "The pop superstar's latest album 'Midnight Gardens' debuts at number one with over 1.8 million first-week sales.",
    excerpt_bn: "পপ সুপারস্টারের সর্বশেষ অ্যালবাম 'মিডনাইট গার্ডেনস' প্রথম সপ্তাহে ১৮ লাখের বেশি বিক্রি নিয়ে এক নম্বরে আত্মপ্রকাশ করেছে।",
    body_en: "<p>Taylor Swift has shattered yet another music industry record as her latest album \"Midnight Gardens\" debuted atop the Billboard 200 with 1.82 million equivalent album units in its first week. This marks her 15th number-one album, surpassing the Beatles' long-standing record of 14.</p><p>The album's lead single \"Starlight Boulevard\" simultaneously topped the Hot 100 for the fourth consecutive week. Swift announced a 120-date world tour to support the album, with tickets selling out within minutes of going on sale.</p>",
    body_bn: "<p>টেইলর সুইফটের সর্বশেষ অ্যালবাম \"মিডনাইট গার্ডেনস\" প্রথম সপ্তাহে ১৮.২ লাখ ইউনিট বিক্রি নিয়ে বিলবোর্ড ২০০-এর শীর্ষে আত্মপ্রকাশ করেছে। এটি তার ১৫তম নম্বর-ওয়ান অ্যালবাম, যা বিটলসের ১৪টির দীর্ঘদিনের রেকর্ড ভেঙে দিয়েছে।</p>",
    category: "Music", tags: %w[trending viral], image_id: 453, featured: false
  },
  {
    title_en: "Netflix Announces Record 300 Million Global Subscribers",
    title_bn: "নেটফ্লিক্স রেকর্ড ৩০ কোটি বৈশ্বিক সাবস্ক্রাইবার ঘোষণা করেছে",
    excerpt_en: "The streaming giant surpasses expectations as its ad-supported tier and live sports programming drive unprecedented growth.",
    excerpt_bn: "বিজ্ঞাপন-সমর্থিত টিয়ার এবং লাইভ স্পোর্টস প্রোগ্রামিং অভূতপূর্ব প্রবৃদ্ধি চালিত করায় স্ট্রিমিং জায়ান্ট প্রত্যাশা ছাড়িয়ে গেছে।",
    body_en: "<p>Netflix has reported reaching 300 million global subscribers in its latest quarterly earnings, surpassing Wall Street estimates by nearly 8 million. The milestone was driven by the rapid adoption of its ad-supported tier, which now accounts for 40% of new sign-ups, and the successful launch of live NFL games on the platform.</p><p>The company's stock surged 12% in after-hours trading. CEO Ted Sarandos attributed the growth to a combination of premium original content, competitive pricing, and the expansion into live events including concerts and comedy specials.</p>",
    body_bn: "<p>নেটফ্লিক্স তার সর্বশেষ ত্রৈমাসিক আয়ের প্রতিবেদনে ৩০ কোটি বৈশ্বিক সাবস্ক্রাইবারে পৌঁছানোর কথা জানিয়েছে। বিজ্ঞাপন-সমর্থিত টিয়ারের দ্রুত গ্রহণ এবং লাইভ এনএফএল গেম সফলভাবে চালু করা এই মাইলফলকের পেছনের চালিকাশক্তি।</p>",
    category: "Television", tags: %w[trending feature], image_id: 536, featured: false
  }
]

# -- Science articles --
articles_data += [
  {
    title_en: "NASA's Artemis III Mission Successfully Lands Humans on Moon's South Pole",
    title_bn: "নাসার আর্টেমিস III মিশন সফলভাবে চাঁদের দক্ষিণ মেরুতে মানুষ অবতরণ করিয়েছে",
    excerpt_en: "Two astronauts make history as the first humans to walk on the lunar south pole, discovering water ice deposits in permanently shadowed craters.",
    excerpt_bn: "দুই নভোচারী চন্দ্রপৃষ্ঠের দক্ষিণ মেরুতে হাঁটা প্রথম মানুষ হিসেবে ইতিহাস সৃষ্টি করেছেন, স্থায়ীভাবে ছায়াযুক্ত গর্তে জলের বরফের সন্ধান পেয়েছেন।",
    body_en: "<p>NASA's Artemis III mission has achieved a historic milestone, landing astronauts Commander Jessica Chen and Dr. Marcus Williams on the Moon's south pole — the first humans to set foot there. The crew spent 6.5 days on the surface, collecting over 70 kilograms of lunar samples and confirming the presence of water ice in permanently shadowed craters.</p><p>The discovery of water ice has profound implications for future lunar habitation and deep-space exploration. NASA Administrator called it a turning point for humanity's future as a multi-planetary species. The next Artemis mission is planned for 2027 with a four-person crew.</p>",
    body_bn: "<p>নাসার আর্টেমিস III মিশন একটি ঐতিহাসিক মাইলফলক অর্জন করেছে, চাঁদের দক্ষিণ মেরুতে নভোচারীদের অবতরণ করিয়েছে — সেখানে পা রাখা প্রথম মানুষ। ক্রু ৭০ কেজির বেশি চন্দ্র নমুনা সংগ্রহ করেছে এবং স্থায়ীভাবে ছায়াযুক্ত গর্তে জলের বরফের উপস্থিতি নিশ্চিত করেছে।</p>",
    category: "Space", tags: %w[breaking space exclusive], image_id: 614, featured: true, breaking: true
  },
  {
    title_en: "Arctic Sea Ice Reaches New Record Low for Third Year Running",
    title_bn: "আর্কটিক সামুদ্রিক বরফ পরপর তৃতীয় বছরে নতুন রেকর্ড সর্বনিম্নে পৌঁছেছে",
    excerpt_en: "Satellite data reveals that Arctic ice coverage has shrunk to 3.2 million square kilometers, accelerating concerns about global climate change.",
    excerpt_bn: "স্যাটেলাইট ডেটা প্রকাশ করেছে আর্কটিক বরফের আচ্ছাদন ৩.২ মিলিয়ন বর্গ কিলোমিটারে সংকুচিত হয়েছে, বৈশ্বিক জলবায়ু পরিবর্তন নিয়ে উদ্বেগ বাড়াচ্ছে।",
    body_en: "<p>New satellite measurements from the European Space Agency confirm that Arctic sea ice has reached its lowest extent ever recorded, covering just 3.2 million square kilometers at its September minimum. This represents a 15% decline from the previous record set just two years ago and is roughly half the average ice coverage measured in the 1980s.</p><p>Climate scientists warn that an ice-free Arctic summer could occur as early as 2035, decades ahead of earlier predictions. The loss of reflective ice cover creates a feedback loop, as darker ocean water absorbs more heat, further accelerating warming in the polar region.</p>",
    body_bn: "<p>ইউরোপীয় মহাকাশ সংস্থার নতুন স্যাটেলাইট পরিমাপ নিশ্চিত করেছে আর্কটিক সামুদ্রিক বরফ এখন পর্যন্ত রেকর্ড করা সর্বনিম্ন স্তরে পৌঁছেছে, সেপ্টেম্বরের ন্যূনতমে মাত্র ৩.২ মিলিয়ন বর্গ কিলোমিটার আচ্ছাদন করে। জলবায়ু বিজ্ঞানীরা সতর্ক করেছেন বরফমুক্ত আর্কটিক গ্রীষ্ম ২০৩৫ সালের মধ্যেই ঘটতে পারে।</p>",
    category: "Environment", tags: %w[breaking climate analysis], image_id: 610, featured: true
  },
  {
    title_en: "Scientists Achieve Nuclear Fusion Net Energy Gain for 100 Hours",
    title_bn: "বিজ্ঞানীরা ১০০ ঘণ্টা ধরে নিউক্লিয়ার ফিউশন নেট এনার্জি গেইন অর্জন করেছেন",
    excerpt_en: "ITER facility sustains fusion reaction producing more energy than consumed, bringing commercial fusion power closer to reality.",
    excerpt_bn: "আইটিইআর সুবিধা ফিউশন বিক্রিয়া বজায় রাখে যা ব্যবহৃত শক্তির চেয়ে বেশি উৎপাদন করে, বাণিজ্যিক ফিউশন শক্তিকে বাস্তবতার কাছাকাছি নিয়ে আসে।",
    body_en: "<p>Scientists at the International Thermonuclear Experimental Reactor in southern France have achieved a sustained nuclear fusion reaction that produced net energy gain for 100 consecutive hours — shattering the previous record of 17 minutes. The reactor generated 11 megawatts of power while consuming only 3 megawatts to sustain the plasma.</p><p>The breakthrough brings commercial fusion energy significantly closer to reality. Several private companies have announced plans to build demonstration power plants by 2032, potentially offering humanity an effectively unlimited clean energy source.</p>",
    body_bn: "<p>দক্ষিণ ফ্রান্সের আন্তর্জাতিক তাপীয় পারমাণবিক পরীক্ষামূলক চুল্লির বিজ্ঞানীরা ১০০ ঘণ্টা ধরে নেট এনার্জি গেইন উৎপাদনকারী একটি টেকসই পারমাণবিক ফিউশন বিক্রিয়া অর্জন করেছেন। চুল্লি মাত্র ৩ মেগাওয়াট ব্যবহার করে ১১ মেগাওয়াট শক্তি উৎপাদন করেছে।</p>",
    category: "Innovation", tags: %w[breaking exclusive feature], image_id: 247, featured: false
  }
]

# -- Opinion articles --
articles_data += [
  {
    title_en: "Why Universal Basic Income Is No Longer a Radical Idea",
    title_bn: "কেন সর্বজনীন মৌলিক আয় আর একটি উগ্র ধারণা নয়",
    excerpt_en: "As AI automation displaces millions of jobs, the case for guaranteed income has moved from fringe economics to mainstream policy debate.",
    excerpt_bn: "এআই অটোমেশন লক্ষ লক্ষ চাকরি প্রতিস্থাপন করায়, গ্যারান্টিযুক্ত আয়ের যুক্তি প্রান্তিক অর্থনীতি থেকে মূলধারার নীতি বিতর্কে চলে এসেছে।",
    body_en: "<p>The idea of paying every citizen a monthly stipend regardless of employment status was once dismissed as utopian fantasy. Today, with AI automation expected to displace up to 40% of current jobs within the next two decades, universal basic income has become the subject of serious policy proposals from both sides of the political spectrum.</p><p>Pilot programs in Finland, Kenya, and several US cities have shown promising results: recipients were more likely to start businesses, pursue education, and maintain better physical and mental health. The question is no longer whether UBI works, but how we fund it at scale.</p>",
    body_bn: "<p>কর্মসংস্থানের অবস্থা নির্বিশেষে প্রতিটি নাগরিককে মাসিক ভাতা প্রদানের ধারণাটি একসময় ইউটোপিয়ান কল্পনা হিসেবে বাতিল করা হতো। আজ, এআই অটোমেশন আগামী দুই দশকে বর্তমান চাকরির ৪০% পর্যন্ত প্রতিস্থাপন করবে বলে আশা করা হচ্ছে, সর্বজনীন মৌলিক আয় রাজনৈতিক বর্ণালীর উভয় পক্ষ থেকে গুরুতর নীতি প্রস্তাবের বিষয় হয়ে উঠেছে।</p>",
    category: "Editorials", tags: %w[editorial analysis ai], image_id: 715, featured: false
  },
  {
    title_en: "The Disappearing Art of Deep Reading in a TikTok World",
    title_bn: "টিকটক বিশ্বে গভীর পাঠের বিলুপ্ত হওয়া শিল্প",
    excerpt_en: "Our shrinking attention spans are not just a personal failing — they represent a cultural crisis that threatens democracy itself.",
    excerpt_bn: "আমাদের সংকুচিত মনোযোগ শুধু ব্যক্তিগত ব্যর্থতা নয় — এটি একটি সাংস্কৃতিক সংকট যা গণতন্ত্রকেই হুমকির মুখে ফেলছে।",
    body_en: "<p>When did we stop reading? Not skimming headlines or scrolling through feeds, but genuinely reading — sitting with a complex argument, wrestling with ideas that challenge our assumptions. Research shows the average adult's sustained attention span has declined from 12 minutes in 2000 to just 47 seconds today.</p><p>This is not merely a generational complaint. The capacity for deep, focused reading is the foundation of informed citizenship. When voters cannot engage with nuanced policy proposals, democracy degrades into a contest of slogans and emotional reactions. We must intentionally rebuild the infrastructure of attention.</p>",
    body_bn: "<p>আমরা কখন পড়া বন্ধ করলাম? শিরোনাম দ্রুত দেখা বা ফিড স্ক্রোল করা নয়, প্রকৃত পাঠ — জটিল যুক্তির সাথে বসে থাকা, আমাদের ধারণাকে চ্যালেঞ্জ করে এমন ধারণার সাথে লড়াই করা। গবেষণায় দেখা গেছে গড় প্রাপ্তবয়স্কের মনোযোগের সময়কাল ২০০০ সালে ১২ মিনিট থেকে আজ মাত্র ৪৭ সেকেন্ডে নেমে এসেছে।</p>",
    category: "Columnists", tags: %w[editorial controversial], image_id: 24, featured: false
  },
  {
    title_en: "Letter to the Editor: Our Schools Need More Funding, Not More Testing",
    title_bn: "সম্পাদকের কাছে চিঠি: আমাদের স্কুলগুলোর আরও অর্থায়ন দরকার, আরও পরীক্ষা নয়",
    excerpt_en: "A veteran teacher argues that standardized testing obsession is destroying the creative spirit of education and burning out our best educators.",
    excerpt_bn: "একজন অভিজ্ঞ শিক্ষক যুক্তি দিচ্ছেন যে মানসম্মত পরীক্ষার আবেশ শিক্ষার সৃজনশীল চেতনা ধ্বংস করছে।",
    body_en: "<p>After 28 years in the classroom, I have watched education policy swing from one extreme to another, but nothing has been more destructive than our obsession with standardized testing. We now spend an average of 35 days per school year on testing and test preparation — that is seven weeks of lost learning time.</p><p>What our students need is not another benchmark assessment but smaller class sizes, up-to-date textbooks, functioning technology, and teachers who are paid enough to stay in the profession. Until we address these fundamentals, no amount of testing will improve outcomes.</p>",
    body_bn: "<p>শ্রেণিকক্ষে ২৮ বছর পর, আমি শিক্ষা নীতিকে এক চরম থেকে অন্য চরমে যেতে দেখেছি, কিন্তু মানসম্মত পরীক্ষার প্রতি আমাদের আবেশের চেয়ে বেশি ধ্বংসাত্মক কিছু হয়নি। আমরা এখন প্রতি স্কুল বছরে গড়ে ৩৫ দিন পরীক্ষা এবং পরীক্ষার প্রস্তুতিতে ব্যয় করি।</p>",
    category: "Letters", tags: %w[editorial controversial], image_id: 180, featured: false
  }
]

# -- Additional articles to fill out each category --
additional_titles = [
  { title_en: "Central Bank Raises Interest Rates to Combat Rising Inflation", title_bn: "ক্রমবর্ধমান মুদ্রাস্ফীতি মোকাবেলায় কেন্দ্রীয় ব্যাংক সুদের হার বাড়িয়েছে", category: "Economy", tags: %w[breaking analysis], image_id: 683 },
  { title_en: "SpaceX Successfully Tests Starship Super Heavy Booster Recovery", title_bn: "স্পেসএক্স সফলভাবে স্টারশিপ সুপার হেভি বুস্টার রিকভারি পরীক্ষা করেছে", category: "Space", tags: %w[breaking space], image_id: 967 },
  { title_en: "Premier League Transfers: Record $2.8 Billion Spent in January Window", title_bn: "প্রিমিয়ার লিগ ট্রান্সফার: জানুয়ারি উইন্ডোতে রেকর্ড ২.৮ বিলিয়ন ডলার ব্যয়", category: "Football", tags: %w[trending exclusive], image_id: 237 },
  { title_en: "Breakthrough Gene Therapy Cures Sickle Cell Disease in Clinical Trial", title_bn: "যুগান্তকারী জিন থেরাপি ক্লিনিক্যাল ট্রায়ালে সিকেল সেল রোগ নিরাময় করেছে", category: "Medical Research", tags: %w[breaking exclusive], image_id: 701 },
  { title_en: "Apple Unveils Mixed Reality Headset with Neural Interface", title_bn: "অ্যাপল নিউরাল ইন্টারফেসসহ মিক্সড রিয়েলিটি হেডসেট উন্মোচন করেছে", category: "Gadgets", tags: %w[trending feature], image_id: 119 },
  { title_en: "Opposition Party Wins Surprise Majority in State Elections", title_bn: "বিরোধী দল রাজ্য নির্বাচনে বিস্ময়কর সংখ্যাগরিষ্ঠতা জিতেছে", category: "Elections", tags: %w[breaking elections], image_id: 433 },
  { title_en: "Global Renewable Energy Investment Surpasses Fossil Fuels for First Time", title_bn: "বৈশ্বিক নবায়নযোগ্য শক্তি বিনিয়োগ প্রথমবারের মতো জীবাশ্ম জ্বালানিকে ছাড়িয়ে গেছে", category: "Environment", tags: %w[climate analysis], image_id: 610 },
  { title_en: "Streaming Wars Intensify as Disney+ Launches Live News Channel", title_bn: "ডিজনি+ লাইভ নিউজ চ্যানেল চালু করায় স্ট্রিমিং যুদ্ধ তীব্র হয়েছে", category: "Television", tags: %w[trending feature], image_id: 536 },
  { title_en: "New Diplomatic Crisis Emerges Between Regional Powers Over Maritime Borders", title_bn: "সামুদ্রিক সীমানা নিয়ে আঞ্চলিক শক্তিগুলোর মধ্যে নতুন কূটনৈতিক সংকট", category: "International", tags: %w[breaking analysis], image_id: 901 },
  { title_en: "Study Links Ultra-Processed Foods to Accelerated Aging", title_bn: "গবেষণায় অতি-প্রক্রিয়াজাত খাবারের সাথে ত্বরান্বিত বার্ধক্যের যোগসূত্র", category: "Nutrition", tags: %w[feature analysis], image_id: 488 },
  { title_en: "Box Office Surprise: Independent Film Outgrosses Marvel Blockbuster", title_bn: "বক্স অফিস চমক: স্বাধীন চলচ্চিত্র মার্ভেল ব্লকবাস্টারকে ছাড়িয়ে গেছে", category: "Movies", tags: %w[trending viral], image_id: 436 },
  { title_en: "Tech Giants Face Antitrust Lawsuits Across Three Continents", title_bn: "টেক জায়ান্টরা তিন মহাদেশে অ্যান্টিট্রাস্ট মামলার সম্মুখীন", category: "Companies", tags: %w[breaking analysis], image_id: 1067 },
  { title_en: "Mental Health Apps See 400% Surge in Downloads Among Young Adults", title_bn: "তরুণ প্রাপ্তবয়স্কদের মধ্যে মানসিক স্বাস্থ্য অ্যাপের ডাউনলোডে ৪০০% বৃদ্ধি", category: "Wellness", tags: %w[trending feature], image_id: 325 },
  { title_en: "Grammy Awards 2026: Hip-Hop Dominates with Record Nominations", title_bn: "গ্র্যামি পুরস্কার ২০২৬: রেকর্ড মনোনয়নে হিপ-হপের আধিপত্য", category: "Music", tags: %w[trending feature], image_id: 453 },
  { title_en: "New Quantum Computer Solves Problem That Would Take Classical Machines 10,000 Years", title_bn: "নতুন কোয়ান্টাম কম্পিউটার এমন সমস্যা সমাধান করেছে যা প্রচলিত মেশিনে ১০,০০০ বছর লাগত", category: "Innovation", tags: %w[breaking ai feature], image_id: 247 },
  { title_en: "NBA Draft 2026: French Teenager Selected as Number One Pick", title_bn: "এনবিএ ড্রাফট ২০২৬: ফরাসি কিশোর এক নম্বর পিক হিসেবে নির্বাচিত", category: "Basketball", tags: %w[breaking exclusive], image_id: 529 },
  { title_en: "Parliament Debates Controversial Social Media Age Restriction Bill", title_bn: "সংসদে বিতর্কিত সোশ্যাল মিডিয়া বয়স সীমাবদ্ধতা বিল নিয়ে বিতর্ক", category: "National", tags: %w[controversial trending], image_id: 1031 },
  { title_en: "Wimbledon Introduces Revolutionary AI Line-Calling System", title_bn: "উইম্বলডন বিপ্লবী এআই লাইন-কলিং সিস্টেম চালু করেছে", category: "Tennis", tags: %w[feature ai], image_id: 342 },
  { title_en: "The Case for Investing in Public Transportation Over Highway Expansion", title_bn: "মহাসড়ক সম্প্রসারণের চেয়ে গণপরিবহনে বিনিয়োগের যুক্তি", category: "Editorials", tags: %w[editorial analysis], image_id: 715 },
  { title_en: "AI Startup Bubble: Are We Heading for a Tech Correction?", title_bn: "এআই স্টার্টআপ বুদবুদ: আমরা কি প্রযুক্তি সংশোধনের দিকে যাচ্ছি?", category: "Startups", tags: %w[analysis ai], image_id: 1067 },
  { title_en: "Bangladesh Cricket Team Achieves Historic Test Series Win in Australia", title_bn: "বাংলাদেশ ক্রিকেট দল অস্ট্রেলিয়ায় ঐতিহাসিক টেস্ট সিরিজ জয় অর্জন করেছে", category: "Sports", tags: %w[breaking exclusive], image_id: 237, featured: true, breaking: true },
  { title_en: "How Social Media Algorithms Are Reshaping Political Discourse", title_bn: "কীভাবে সোশ্যাল মিডিয়া অ্যালগরিদম রাজনৈতিক আলোচনাকে পুনর্গঠন করছে", category: "Columnists", tags: %w[editorial controversial ai], image_id: 24 },
  { title_en: "Pacific Island Nation Becomes First Country to Relocate Due to Rising Seas", title_bn: "প্রশান্ত মহাসাগরীয় দ্বীপ রাষ্ট্র সমুদ্রপৃষ্ঠের উচ্চতা বৃদ্ধির কারণে স্থানান্তরিত প্রথম দেশ", category: "Environment", tags: %w[breaking climate], image_id: 610 },
  { title_en: "Readers Respond: The Future of Work in an AI-Powered Economy", title_bn: "পাঠকদের প্রতিক্রিয়া: এআই-চালিত অর্থনীতিতে কাজের ভবিষ্যৎ", category: "Letters", tags: %w[editorial ai], image_id: 180 }
]

# Generate body content for additional articles
additional_titles.each do |data|
  excerpt_en = Faker::Lorem.paragraph(sentence_count: 3)
  excerpt_bn = "এটি একটি গুরুত্বপূর্ণ সংবাদ যা দেশ ও বিশ্বের জন্য তাৎপর্যপূর্ণ প্রভাব বহন করে।"
  body_en = "<p>#{Faker::Lorem.paragraph(sentence_count: 5)}</p><p>#{Faker::Lorem.paragraph(sentence_count: 4)}</p><p>#{Faker::Lorem.paragraph(sentence_count: 4)}</p>"
  body_bn = "<p>#{excerpt_bn} বিশেষজ্ঞরা বলছেন এই উন্নয়ন আগামী দিনে ব্যাপক পরিবর্তন আনতে পারে।</p>"

  articles_data << data.merge(
    excerpt_en: excerpt_en,
    excerpt_bn: excerpt_bn,
    body_en: body_en,
    body_bn: body_bn
  )
end

# Create all articles
articles_data.each_with_index do |data, idx|
  article = find_or_create_translated!(Article, :title, data[:title_en]) do |a|
    a.title_bn = data[:title_bn]
    a.excerpt_en = data[:excerpt_en]
    a.excerpt_bn = data[:excerpt_bn]
    a.category = cat_map[data[:category]] || all_categories.sample
    a.author = staff.sample
    a.status = data[:status] || :published
    a.published_at = a.published? ? Faker::Time.between(from: 30.days.ago, to: Time.current) : nil
    a.featured = data[:featured] || false
    a.breaking = data[:breaking] || false
    a.views_count = rand(100..5000)
    a.comments_enabled = true
    a.meta_title_en = data[:title_en]
    a.meta_description_en = data[:excerpt_en]
    a.body_en = data[:body_en]
    a.body_bn = data[:body_bn]
  end

  if data[:tag_names].present? && article.article_tags.empty?
    article.tags = data[:tag_names].filter_map { |name| tag_map[name] }
  elsif data[:tags].present? && article.article_tags.empty?
    article.tags = data[:tags].filter_map { |name| tag_map[name] }
  end

  attach_image(article, :featured_image, data[:image_id]) if data[:image_id]
  print "."
end
puts ""
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
    content_en: "<h2>Our Mission</h2><p>We are committed to delivering accurate, unbiased, and timely news coverage to our readers. Founded in 2020, our newsroom brings together experienced journalists, data analysts, and subject matter experts dedicated to upholding the highest standards of journalism.</p><p>Our editorial team operates independently, ensuring that our reporting remains free from commercial or political influence. We believe that informed citizens are the foundation of a healthy democracy.</p><p>We cover national and international affairs, business, technology, sports, health, science, entertainment, and opinion — all through the lens of rigorous fact-checking and balanced analysis.</p>",
    content_bn: "<h2>আমাদের লক্ষ্য</h2><p>আমরা আমাদের পাঠকদের কাছে সঠিক, নিরপেক্ষ এবং সময়োপযোগী সংবাদ পরিবেশনে প্রতিশ্রুতিবদ্ধ। ২০২০ সালে প্রতিষ্ঠিত, আমাদের সংবাদকক্ষ অভিজ্ঞ সাংবাদিক, তথ্য বিশ্লেষক এবং বিষয় বিশেষজ্ঞদের একত্রিত করে।</p><p>আমরা জাতীয় ও আন্তর্জাতিক বিষয়, ব্যবসা, প্রযুক্তি, খেলাধুলা, স্বাস্থ্য, বিজ্ঞান, বিনোদন এবং মতামত — সবকিছু কঠোর তথ্য-যাচাই এবং ভারসাম্যপূর্ণ বিশ্লেষণের মাধ্যমে কভার করি।</p>" },
  { en: "Contact", bn: "যোগাযোগ", nav: true, pos: 1,
    content_en: "<h2>Get in Touch</h2><p>We value your feedback and are always happy to hear from our readers.</p><p><strong>General Inquiries:</strong> contact@newsportal.com</p><p><strong>News Tips:</strong> tips@newsportal.com</p><p><strong>Advertising:</strong> ads@newsportal.com</p><p><strong>Address:</strong> 123 Press Avenue, Dhaka 1205, Bangladesh</p><p><strong>Phone:</strong> +880 2 1234 5678</p>",
    content_bn: "<h2>যোগাযোগ করুন</h2><p>আমরা আপনার মতামত মূল্য দিই এবং সর্বদা আমাদের পাঠকদের কাছ থেকে শুনতে খুশি।</p><p><strong>সাধারণ জিজ্ঞাসা:</strong> contact@newsportal.com</p><p><strong>সংবাদ টিপস:</strong> tips@newsportal.com</p><p><strong>বিজ্ঞাপন:</strong> ads@newsportal.com</p><p><strong>ঠিকানা:</strong> ১২৩ প্রেস এভিনিউ, ঢাকা ১২০৫, বাংলাদেশ</p>" },
  { en: "Privacy Policy", bn: "গোপনীয়তা নীতি", nav: true, pos: 2,
    content_en: "<h2>Privacy Policy</h2><p>Your privacy is important to us. This policy explains how we collect, use, and protect your personal information when you visit our website.</p><p><strong>Information We Collect:</strong> We collect information you provide directly, such as when you create an account, subscribe to our newsletter, or leave a comment. We also automatically collect certain technical data including your IP address, browser type, and pages visited.</p><p><strong>How We Use Your Data:</strong> We use your information to deliver personalized content, improve our services, and communicate with you about news and updates. We never sell your personal data to third parties.</p><p><strong>Your Rights:</strong> You have the right to access, correct, or delete your personal data at any time by contacting us at privacy@newsportal.com.</p>",
    content_bn: "<h2>গোপনীয়তা নীতি</h2><p>আপনার গোপনীয়তা আমাদের কাছে গুরুত্বপূর্ণ। এই নীতি ব্যাখ্যা করে কিভাবে আমরা আপনার ব্যক্তিগত তথ্য সংগ্রহ, ব্যবহার এবং সুরক্ষা করি।</p><p>আমরা কখনও আপনার ব্যক্তিগত তথ্য তৃতীয় পক্ষের কাছে বিক্রি করি না। আপনি যেকোনো সময় privacy@newsportal.com এ যোগাযোগ করে আপনার তথ্য অ্যাক্সেস, সংশোধন বা মুছে ফেলতে পারেন।</p>" },
  { en: "Terms of Service", bn: "সেবার শর্তাবলী", nav: true, pos: 3,
    content_en: "<h2>Terms of Service</h2><p>By using this website, you agree to the following terms and conditions. Please read them carefully.</p><p><strong>Use of Content:</strong> All content published on this site is protected by copyright. You may share articles via social media or email for personal, non-commercial use. Republication or commercial use requires written permission.</p><p><strong>User Accounts:</strong> You are responsible for maintaining the security of your account credentials. You agree not to share your password or allow unauthorized access to your account.</p><p><strong>Comments Policy:</strong> We welcome constructive discussion. Comments that contain hate speech, personal attacks, spam, or misinformation will be removed. Repeat violators may have their accounts suspended.</p>",
    content_bn: "<h2>সেবার শর্তাবলী</h2><p>এই ওয়েবসাইট ব্যবহার করে আপনি নিম্নলিখিত শর্তাবলী মেনে চলতে সম্মত হচ্ছেন।</p><p>এই সাইটে প্রকাশিত সমস্ত বিষয়বস্তু কপিরাইট দ্বারা সুরক্ষিত। ব্যক্তিগত, অ-বাণিজ্যিক ব্যবহারের জন্য আপনি সোশ্যাল মিডিয়া বা ইমেইলের মাধ্যমে নিবন্ধ শেয়ার করতে পারেন।</p>" }
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

# 10. Create realistic advertisements with images
advertisements_data = [
  {
    title_en: "Grameenphone 5G — Blazing Fast Internet Nationwide",
    title_bn: "গ্রামীণফোন ৫জি — সারাদেশে অতিদ্রুত ইন্টারনেট",
    description_en: "Experience next-generation 5G speeds up to 1 Gbps. Stream, game, and work without limits. Upgrade your plan today!",
    description_bn: "১ জিবিপিএস পর্যন্ত পরবর্তী প্রজন্মের ৫জি গতি উপভোগ করুন। সীমাহীন স্ট্রিমিং, গেমিং এবং কাজ করুন। আজই আপনার প্ল্যান আপগ্রেড করুন!",
    placement: :top_banner, target_url: "https://www.grameenphone.com/5g",
    image_id: 1, image_w: 1200, image_h: 300,
    starts_at: 14.days.ago, ends_at: 90.days.from_now,
    impressions_count: 48_520, clicks_count: 1_934
  },
  {
    title_en: "Bkash — Send Money Instantly, Anytime, Anywhere",
    title_bn: "বিকাশ — যেকোনো সময়, যেকোনো জায়গায় তাৎক্ষণিক টাকা পাঠান",
    description_en: "Bangladesh's #1 mobile financial service. Pay bills, send money, and shop online securely with bKash.",
    description_bn: "বাংলাদেশের এক নম্বর মোবাইল আর্থিক সেবা। বিকাশ দিয়ে নিরাপদে বিল পরিশোধ করুন, টাকা পাঠান এবং অনলাইনে কেনাকাটা করুন।",
    placement: :sidebar, target_url: "https://www.bkash.com",
    image_id: 60, image_w: 400, image_h: 500,
    starts_at: 7.days.ago, ends_at: 120.days.from_now,
    impressions_count: 32_180, clicks_count: 2_105
  },
  {
    title_en: "Daraz Mega Sale — Up to 70% Off Electronics & Fashion",
    title_bn: "দারাজ মেগা সেল — ইলেকট্রনিক্স ও ফ্যাশনে ৭০% পর্যন্ত ছাড়",
    description_en: "Shop the biggest sale of the season! Smartphones, laptops, clothing & more at unbeatable prices. Free shipping on orders over ৳999.",
    description_bn: "মৌসুমের সবচেয়ে বড় সেলে কেনাকাটা করুন! স্মার্টফোন, ল্যাপটপ, পোশাক এবং আরও অনেক কিছু অবিশ্বাস্য মূল্যে। ৳৯৯৯ এর উপরে অর্ডারে বিনামূল্যে ডেলিভারি।",
    placement: :in_feed, target_url: "https://www.daraz.com.bd/mega-sale",
    image_id: 26, image_w: 600, image_h: 400,
    starts_at: 3.days.ago, ends_at: 30.days.from_now,
    impressions_count: 21_740, clicks_count: 3_482
  },
  {
    title_en: "Subscribe to NewsPortal Premium — Ad-Free Reading",
    title_bn: "নিউজপোর্টাল প্রিমিয়ামে সাবস্ক্রাইব করুন — বিজ্ঞাপনমুক্ত পাঠ",
    description_en: "Enjoy unlimited access to all articles, exclusive investigations, and early morning briefings. First month free — cancel anytime.",
    description_bn: "সব নিবন্ধে সীমাহীন প্রবেশাধিকার, একচেটিয়া অনুসন্ধান এবং ভোরের সংবাদ সংক্ষেপ উপভোগ করুন। প্রথম মাস বিনামূল্যে — যেকোনো সময় বাতিল করুন।",
    placement: :popup, target_url: "https://newsportal.com/premium",
    image_id: 380, image_w: 600, image_h: 400,
    starts_at: 1.day.ago, ends_at: 60.days.from_now,
    impressions_count: 8_920, clicks_count: 712
  },
  {
    title_en: "IELTS Preparation Course — Score 7.0+ Guaranteed",
    title_bn: "আইইএলটিএস প্রস্তুতি কোর্স — ৭.০+ স্কোর নিশ্চিত",
    description_en: "Join 50,000+ successful students. Expert tutors, mock tests, and personalized study plans. Enroll now and get 30% off!",
    description_bn: "৫০,০০০+ সফল শিক্ষার্থীর সাথে যোগ দিন। বিশেষজ্ঞ প্রশিক্ষক, মক টেস্ট এবং ব্যক্তিগতকৃত পড়াশোনার পরিকল্পনা। এখনই ভর্তি হন এবং ৩০% ছাড় পান!",
    placement: :sidebar, target_url: "https://example.com/ielts-prep",
    image_id: 20, image_w: 400, image_h: 500,
    starts_at: 10.days.ago, ends_at: 45.days.from_now,
    impressions_count: 15_630, clicks_count: 1_247
  },
  {
    title_en: "Robi 4G — Unlimited Data Packs Starting at ৳99",
    title_bn: "রবি ৪জি — ৳৯৯ থেকে আনলিমিটেড ডেটা প্যাক",
    description_en: "Stay connected with Robi's affordable unlimited data plans. Lightning-fast 4G coverage across 64 districts.",
    description_bn: "রবির সাশ্রয়ী আনলিমিটেড ডেটা প্ল্যানে সংযুক্ত থাকুন। ৬৪ জেলায় অতিদ্রুত ৪জি কভারেজ।",
    placement: :top_banner, target_url: "https://www.robi.com.bd/data-packs",
    image_id: 160, image_w: 1200, image_h: 300,
    starts_at: 5.days.ago, ends_at: 75.days.from_now,
    impressions_count: 37_890, clicks_count: 1_516
  },
  {
    title_en: "Pathao — Ride, Food, Courier All in One App",
    title_bn: "পাঠাও — রাইড, খাবার, কুরিয়ার একটি অ্যাপেই",
    description_en: "Download the Pathao app and get your first ride free! Food delivery in 30 minutes or less. Available in Dhaka, Chittagong & Sylhet.",
    description_bn: "পাঠাও অ্যাপ ডাউনলোড করুন এবং প্রথম রাইড বিনামূল্যে পান! ৩০ মিনিট বা তার কমে খাবার ডেলিভারি। ঢাকা, চট্টগ্রাম ও সিলেটে পাওয়া যায়।",
    placement: :in_feed, target_url: "https://pathao.com/download",
    image_id: 183, image_w: 600, image_h: 400,
    starts_at: 2.days.ago, ends_at: 50.days.from_now,
    impressions_count: 19_450, clicks_count: 2_723
  }
]

advertisements_data.each_with_index do |data, idx|
  ad = Advertisement.find_or_create_by!(
    title: { "en" => data[:title_en] }
  ) do |a|
    a.title_en = data[:title_en]
    a.title_bn = data[:title_bn]
    a.description_en = data[:description_en]
    a.description_bn = data[:description_bn]
    a.ad_type = :image
    a.placement = data[:placement]
    a.position = idx
    a.target_url = data[:target_url]
    a.status = :active
    a.starts_at = data[:starts_at]
    a.ends_at = data[:ends_at]
    a.impressions_count = data[:impressions_count]
    a.clicks_count = data[:clicks_count]
  end
  attach_image(ad, :image, data[:image_id], width: data[:image_w], height: data[:image_h])
end

# Add one HTML embed ad as example (Google AdSense style)
Advertisement.find_or_create_by!(title: { "en" => "Google AdSense — Responsive Display Ad" }) do |a|
  a.title_en = "Google AdSense — Responsive Display Ad"
  a.title_bn = "গুগল অ্যাডসেন্স — রেসপন্সিভ ডিসপ্লে বিজ্ঞাপন"
  a.ad_type = :html
  a.placement = :sidebar
  a.position = 10
  a.embed_code = <<~HTML
    <div style="padding:24px;background:linear-gradient(135deg,#f0f9ff,#e0f2fe);border:1px solid #bae6fd;border-radius:12px;text-align:center;">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin:0 auto 12px;display:block;"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18"/><path d="M9 21V9"/></svg>
      <p style="color:#0369a1;font-weight:600;font-size:15px;margin:0 0 4px;">Google AdSense</p>
      <p style="color:#64748b;font-size:13px;margin:0;">Replace with your ad network code</p>
    </div>
  HTML
  a.status = :active
  a.starts_at = 3.days.ago
  a.ends_at = 180.days.from_now
  a.impressions_count = 12_340
  a.clicks_count = 198
end
puts "  Created #{Advertisement.count} advertisements"

puts ""
puts "Seeding complete!"
puts "Login: admin@newsportal.com / password123"
