require "rails_helper"

RSpec.describe Comments::CreateService do
  let(:article) { create(:article, :published) }
  let(:reader) { create(:user) }
  let(:editor) { create(:user, :editor) }

  describe ".call" do
    let(:params) { { body: "Great article!" } }

    context "as a reader" do
      it "creates a pending comment" do
        result = described_class.call(article: article, user: reader, params: params)
        expect(result).to be_success
        expect(result.data).to be_pending
      end
    end

    context "as staff" do
      it "auto-approves the comment" do
        result = described_class.call(article: article, user: editor, params: params)
        expect(result).to be_success
        expect(result.data).to be_approved
      end
    end

    context "with invalid params" do
      it "returns failure" do
        result = described_class.call(article: article, user: reader, params: { body: "" })
        expect(result).to be_failure
        expect(result.errors).to be_present
      end
    end
  end
end
