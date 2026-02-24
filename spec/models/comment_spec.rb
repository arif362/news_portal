require "rails_helper"

RSpec.describe Comment do
  describe "validations" do
    subject { build(:comment) }

    it { is_expected.to be_valid }

    it "requires body" do
      subject.body = nil
      expect(subject).not_to be_valid
    end

    it "limits body to 2000 characters" do
      subject.body = "a" * 2001
      expect(subject).not_to be_valid
    end

    it "requires article to allow comments" do
      subject.article.comments_enabled = false
      expect(subject).not_to be_valid
    end
  end

  describe "scopes" do
    let!(:approved) { create(:comment, :approved) }
    let!(:pending) { create(:comment) }
    let!(:rejected) { create(:comment, :rejected) }

    it ".approved returns approved comments" do
      expect(described_class.approved).to include(approved)
      expect(described_class.approved).not_to include(pending, rejected)
    end

    it ".pending_review returns pending comments" do
      expect(described_class.pending_review).to include(pending)
    end
  end
end
