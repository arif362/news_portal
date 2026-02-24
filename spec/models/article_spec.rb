require "rails_helper"

RSpec.describe Article do
  describe "validations" do
    subject { build(:article) }

    it { is_expected.to be_valid }

    it "requires title" do
      subject.title = nil
      expect(subject).not_to be_valid
    end

    it "requires category" do
      subject.category = nil
      expect(subject).not_to be_valid
    end

    it "auto-sets published_at when transitioning to published" do
      subject.status = :published
      subject.valid?
      expect(subject.published_at).to be_present
    end

    it "limits excerpt to 500 characters" do
      subject.excerpt = "a" * 501
      expect(subject).not_to be_valid
    end
  end

  describe "scopes" do
    let!(:published) { create(:article, :published) }
    let!(:draft) { create(:article) }
    let!(:featured) { create(:article, :featured) }

    it ".published returns only published articles" do
      expect(described_class.published).to include(published, featured)
      expect(described_class.published).not_to include(draft)
    end

    it ".drafts returns only draft articles" do
      expect(described_class.drafts).to include(draft)
      expect(described_class.drafts).not_to include(published)
    end

    it ".featured returns only featured published articles" do
      expect(described_class.featured).to include(featured)
      expect(described_class.featured).not_to include(published)
    end
  end

  describe "#reading_time" do
    it "returns at least 1 minute" do
      article = build(:article, body: "Short")
      expect(article.reading_time).to be >= 1
    end
  end

  describe "#increment_views!" do
    it "increments the views count" do
      article = create(:article, :published)
      expect { article.increment_views! }.to change { article.reload.views_count }.by(1)
    end
  end
end
