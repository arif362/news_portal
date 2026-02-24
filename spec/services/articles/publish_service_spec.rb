require "rails_helper"

RSpec.describe Articles::PublishService do
  let(:editor) { create(:user, :editor) }
  let(:reader) { create(:user) }
  let(:article) { create(:article, body: "<p>Content</p>") }

  describe ".call" do
    context "with valid editor" do
      it "publishes the article" do
        result = described_class.call(article: article, user: editor)
        expect(result).to be_success
        expect(article.reload).to be_published
        expect(article.published_at).to be_present
      end
    end

    context "with unauthorized user" do
      it "returns failure" do
        result = described_class.call(article: article, user: reader)
        expect(result).to be_failure
        expect(result.errors).to include("Only editors and admins can publish articles")
      end
    end

    context "with invalid article" do
      it "returns failure when body is blank" do
        article.body = nil
        result = described_class.call(article: article, user: editor)
        expect(result).to be_failure
      end
    end
  end
end
