require "rails_helper"

RSpec.describe Category do
  describe "validations" do
    subject { build(:category) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires unique name" do
      create(:category, name: "Tech")
      subject.name = "Tech"
      expect(subject).not_to be_valid
    end
  end

  describe "scopes" do
    let!(:active_root) { create(:category) }
    let!(:inactive) { create(:category, :inactive) }
    let!(:child) { create(:category, :with_parent) }

    it ".active returns only active categories" do
      expect(described_class.active).to include(active_root)
      expect(described_class.active).not_to include(inactive)
    end

    it ".roots returns only root categories" do
      expect(described_class.roots).to include(active_root)
      expect(described_class.roots).not_to include(child)
    end
  end

  describe "hierarchy validation" do
    it "prevents self-referencing parent" do
      category = create(:category)
      category.parent_id = category.id
      expect(category).not_to be_valid
    end
  end
end
