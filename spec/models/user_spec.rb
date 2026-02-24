require "rails_helper"

RSpec.describe User do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to be_valid }

    it "requires email" do
      subject.email = nil
      expect(subject).not_to be_valid
    end

    it "requires unique email (case insensitive)" do
      create(:user, email: "test@example.com")
      subject.email = "TEST@example.com"
      expect(subject).not_to be_valid
    end

    it "requires valid email format" do
      subject.email = "not-an-email"
      expect(subject).not_to be_valid
    end

    it "requires username" do
      subject.username = nil
      expect(subject).not_to be_valid
    end

    it "requires unique username" do
      create(:user, username: "testuser")
      subject.username = "testuser"
      expect(subject).not_to be_valid
    end

    it "requires password minimum 8 characters" do
      subject.password = "short"
      expect(subject).not_to be_valid
    end

    it "requires first_name and last_name" do
      subject.first_name = nil
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "has many articles" do
      assoc = described_class.reflect_on_association(:articles)
      expect(assoc.macro).to eq :has_many
    end

    it "has many comments" do
      assoc = described_class.reflect_on_association(:comments)
      expect(assoc.macro).to eq :has_many
    end
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq "John Doe"
    end
  end

  describe "#staff?" do
    it "returns true for authors" do
      expect(build(:user, :author).staff?).to be true
    end

    it "returns true for editors" do
      expect(build(:user, :editor).staff?).to be true
    end

    it "returns true for admins" do
      expect(build(:user, :admin).staff?).to be true
    end

    it "returns false for readers" do
      expect(build(:user).staff?).to be false
    end
  end

  describe "#track_sign_in!" do
    it "updates sign-in tracking fields" do
      user = create(:user)
      user.track_sign_in!(ip: "127.0.0.1")
      user.reload
      expect(user.sign_in_count).to eq 1
      expect(user.last_sign_in_ip).to eq "127.0.0.1"
      expect(user.last_sign_in_at).to be_present
    end
  end

  describe "password reset" do
    let(:user) { create(:user) }

    it "generates a reset token" do
      user.generate_password_reset_token!
      expect(user[:password_reset_token]).to be_present
      expect(user.password_reset_sent_at).to be_present
    end

    it "validates token expiry" do
      user.generate_password_reset_token!
      expect(user.password_reset_token_valid?).to be true

      user.update!(password_reset_sent_at: 3.hours.ago)
      expect(user.password_reset_token_valid?).to be false
    end

    it "clears the reset token" do
      user.generate_password_reset_token!
      user.clear_password_reset_token!
      expect(user[:password_reset_token]).to be_nil
    end
  end
end
