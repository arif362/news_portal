require "faker"

puts "Seeding database..."

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

# 5. Create categories with hierarchy
categories_data = {
  "Politics" => [ "National", "International", "Elections" ],
  "Technology" => [ "AI & Machine Learning", "Startups", "Gadgets" ],
  "Business" => [ "Markets", "Economy", "Companies" ],
  "Sports" => [ "Football", "Basketball", "Tennis" ],
  "Health" => [ "Wellness", "Medical Research", "Nutrition" ],
  "Entertainment" => [ "Movies", "Music", "Television" ],
  "Science" => [ "Space", "Environment", "Innovation" ],
  "Opinion" => [ "Editorials", "Letters", "Columnists" ]
}

all_categories = []
categories_data.each_with_index do |(parent_name, children), idx|
  parent = Category.find_or_create_by!(name: parent_name) do |c|
    c.description = Faker::Lorem.sentence(word_count: 10)
    c.position = idx
    c.active = true
  end
  all_categories << parent

  children.each_with_index do |child_name, cidx|
    child = Category.find_or_create_by!(name: child_name) do |c|
      c.description = Faker::Lorem.sentence(word_count: 8)
      c.parent = parent
      c.position = cidx
      c.active = true
    end
    all_categories << child
  end
end
puts "  Created #{all_categories.size} categories"

# 6. Create tags
tag_names = %w[breaking exclusive analysis investigation feature interview
               editorial trending viral controversial climate
               cryptocurrency pandemic elections ai space]
tags = tag_names.map do |name|
  Tag.find_or_create_by!(name: name)
end
puts "  Created #{tags.size} tags"

# 7. Create articles
staff = [ admin, editor ] + authors
60.times do |i|
  title = "#{Faker::Lorem.sentence(word_count: rand(6..10)).chomp('.')} ##{i + 1}"
  article = Article.find_or_create_by!(title: title) do |a|
    a.excerpt = Faker::Lorem.paragraph(sentence_count: 2)
    a.category = all_categories.sample
    a.author = staff.sample
    a.status = [ :draft, :published, :published, :published, :published ].sample
    a.published_at = a.published? ? Faker::Time.between(from: 30.days.ago, to: Time.current) : nil
    a.featured = [ true, false, false, false ].sample
    a.breaking = [ true, false, false, false, false, false ].sample
    a.views_count = rand(0..5000)
    a.comments_enabled = true
    a.meta_title = a.title
    a.meta_description = a.excerpt
    a.body = Faker::Lorem.paragraphs(number: rand(5..12)).map { |p| "<p>#{p}</p>" }.join
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

# 9. Create static pages
[
  { title: "About Us", show_in_navigation: true, position: 0,
    content: "<h2>Our Mission</h2><p>#{Faker::Lorem.paragraphs(number: 3).join('</p><p>')}</p>" },
  { title: "Contact", show_in_navigation: true, position: 1,
    content: "<p>Email us at contact@newsportal.com</p><p>#{Faker::Lorem.paragraphs(number: 2).join('</p><p>')}</p>" },
  { title: "Privacy Policy", show_in_navigation: true, position: 2,
    content: "<p>#{Faker::Lorem.paragraphs(number: 5).join('</p><p>')}</p>" },
  { title: "Terms of Service", show_in_navigation: true, position: 3,
    content: "<p>#{Faker::Lorem.paragraphs(number: 5).join('</p><p>')}</p>" }
].each do |page_data|
  Page.find_or_create_by!(title: page_data[:title]) do |p|
    p.status = :published
    p.show_in_navigation = page_data[:show_in_navigation]
    p.position = page_data[:position]
    p.author = admin
    p.body = page_data[:content]
  end
end
puts "  Created #{Page.count} pages"

puts ""
puts "Seeding complete!"
puts "Login: admin@newsportal.com / password123"
