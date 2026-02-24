require "rails_helper"

RSpec.describe Advertisement do
  describe "validations" do
    subject { build(:advertisement) }

    it { is_expected.to be_valid }

    it "requires title" do
      subject.title = nil
      expect(subject).not_to be_valid
    end

    it "requires placement" do
      subject.placement = nil
      expect(subject).not_to be_valid
    end

    it "requires target_url for image ads" do
      subject.ad_type = :image
      subject.target_url = nil
      expect(subject).not_to be_valid
    end

    it "requires embed_code for html ads" do
      subject.ad_type = :html
      subject.embed_code = nil
      subject.target_url = nil
      expect(subject).not_to be_valid
    end

    it "allows blank target_url for html ads" do
      subject.ad_type = :html
      subject.embed_code = "<div>Ad</div>"
      subject.target_url = nil
      expect(subject).to be_valid
    end
  end

  describe "enums" do
    it "defines ad_type enum" do
      expect(described_class.ad_types).to eq("image" => 0, "html" => 1)
    end

    it "defines placement enum" do
      expect(described_class.placements).to eq(
        "top_banner" => 0, "sidebar" => 1, "in_feed" => 2, "popup" => 3
      )
    end

    it "defines status enum" do
      expect(described_class.statuses).to eq(
        "draft" => 0, "active" => 1, "paused" => 2, "expired" => 3
      )
    end
  end

  describe "scopes" do
    let!(:active_ad) { create(:advertisement, :active) }
    let!(:draft_ad) { create(:advertisement) }
    let!(:expired_ad) { create(:advertisement, :expired) }
    let!(:future_ad) { create(:advertisement, status: :active, starts_at: 5.days.from_now) }

    describe ".active_now" do
      it "returns only active ads within schedule" do
        expect(described_class.active_now).to include(active_ad)
        expect(described_class.active_now).not_to include(draft_ad, expired_ad, future_ad)
      end
    end

    describe ".for_placement" do
      it "returns active ads for a specific placement" do
        sidebar_ad = create(:advertisement, :active, :sidebar)
        expect(described_class.for_placement(:sidebar)).to include(sidebar_ad)
        expect(described_class.for_placement(:sidebar)).not_to include(active_ad)
      end
    end
  end

  describe "#ctr" do
    it "returns 0.0 when no impressions" do
      ad = build(:advertisement, impressions_count: 0, clicks_count: 0)
      expect(ad.ctr).to eq(0.0)
    end

    it "calculates correct click-through rate" do
      ad = build(:advertisement, impressions_count: 1000, clicks_count: 25)
      expect(ad.ctr).to eq(2.5)
    end
  end

  describe "#increment_impressions!" do
    it "increments the impressions count" do
      ad = create(:advertisement, :active)
      expect { ad.increment_impressions! }.to change { ad.reload.impressions_count }.by(1)
    end
  end

  describe "#increment_clicks!" do
    it "increments the clicks count" do
      ad = create(:advertisement, :active)
      expect { ad.increment_clicks! }.to change { ad.reload.clicks_count }.by(1)
    end
  end

  describe "#running?" do
    it "returns true for active ad within schedule" do
      ad = build(:advertisement, :active)
      expect(ad.running?).to be true
    end

    it "returns false for draft ad" do
      ad = build(:advertisement)
      expect(ad.running?).to be false
    end

    it "returns false for active ad not yet started" do
      ad = build(:advertisement, status: :active, starts_at: 5.days.from_now)
      expect(ad.running?).to be false
    end
  end

  describe "#days_remaining" do
    it "returns nil when no end date" do
      ad = build(:advertisement, ends_at: nil)
      expect(ad.days_remaining).to be_nil
    end

    it "returns remaining days" do
      ad = build(:advertisement, ends_at: 10.days.from_now)
      expect(ad.days_remaining).to eq(10)
    end

    it "returns 0 for expired ads" do
      ad = build(:advertisement, ends_at: 1.day.ago)
      expect(ad.days_remaining).to eq(0)
    end
  end

  describe "#scheduled?" do
    it "returns true when starts_at is set" do
      ad = build(:advertisement, starts_at: Time.current)
      expect(ad.scheduled?).to be true
    end

    it "returns false when neither date is set" do
      ad = build(:advertisement, starts_at: nil, ends_at: nil)
      expect(ad.scheduled?).to be false
    end
  end
end
