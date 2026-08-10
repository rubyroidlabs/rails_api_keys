# frozen_string_literal: true

RSpec.describe "RailsApiKeys::Authentication", type: :request do
  let(:user) { User.create!(email: "manager@example.com") }
  let!(:pair) { RailsApiKeys::ApiKey.generate_for!(owner: user, name: "API", permission: permission) }
  let(:key) { pair.first }
  let(:raw) { pair.last }
  let(:permission) { :read }

  def auth_headers(token = raw)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "authenticate_api_key!" do
    it "allows a valid bearer token and exposes the owner" do
      get "/api/v1/ping", headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["owner_id"]).to eq(user.id)
      expect(body["permission"]).to eq("read")
    end

    it "returns 401 without a token" do
      get "/api/v1/ping"

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
    end

    it "returns 401 for an invalid token" do
      get "/api/v1/ping", headers: auth_headers("dummy_ak_invalid")

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for a revoked key" do
      key.revoke!

      get "/api/v1/ping", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 when the owner is inactive" do
      user.update!(active: false)

      get "/api/v1/ping", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "require_api_permission!" do
    context "with a read key" do
      let(:permission) { :read }

      it "allows read" do
        get "/api/v1/ping", params: { required_permission: "read" }, headers: auth_headers

        expect(response).to have_http_status(:ok)
      end

      it "forbids write" do
        get "/api/v1/ping", params: { required_permission: "write" }, headers: auth_headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq("error" => "Forbidden")
      end
    end

    context "with a read_write key" do
      let(:permission) { :read_write }

      it "allows read and write" do
        get "/api/v1/ping", params: { required_permission: "read" }, headers: auth_headers
        expect(response).to have_http_status(:ok)

        get "/api/v1/ping", params: { required_permission: "write" }, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
