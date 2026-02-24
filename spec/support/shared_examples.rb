# Shared examples for common API response patterns

RSpec.shared_examples "returns http success" do
  it { expect(response).to have_http_status(:ok) }
end

RSpec.shared_examples "returns http not found" do
  it { expect(response).to have_http_status(:not_found) }
end

RSpec.shared_examples "returns http unauthorized" do
  it { expect(response).to have_http_status(:unauthorized) }
end

RSpec.shared_examples "returns http unprocessable entity" do
  it { expect(response).to have_http_status(:unprocessable_entity) }
end
