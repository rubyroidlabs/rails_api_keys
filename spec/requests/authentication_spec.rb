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

  describe "method-based permissions" do
    context "with a read key" do
      let(:permission) { :read }

      it "allows GET" do
        get "/api/v1/ping", headers: auth_headers

        expect(response).to have_http_status(:ok)
      end

      it "forbids POST" do
        post "/api/v1/ping", headers: auth_headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq("error" => "Forbidden")
      end
    end

    context "with a read_write key" do
      let(:permission) { :read_write }

      it "allows GET" do
        get "/api/v1/ping", headers: auth_headers

        expect(response).to have_http_status(:ok)
      end

      it "allows POST" do
        post "/api/v1/ping", headers: auth_headers

        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "IP allowlist enforcement" do
    let!(:pair) do
      RailsApiKeys::ApiKey.generate_for!(
        owner: user,
        name: "IP Scoped",
        permission: :read,
        allowed_ips: [ "203.0.113.10", "10.0.0.0/24" ]
      )
    end

    it "allows requests from an allowed single IP and updates last_used_at" do
      get "/api/v1/ping", headers: auth_headers, env: { "REMOTE_ADDR" => "203.0.113.10" }

      expect(response).to have_http_status(:ok)
      expect(key.reload.last_used_at).to be_present
    end

    it "allows requests from an allowed CIDR range" do
      get "/api/v1/ping", headers: auth_headers, env: { "REMOTE_ADDR" => "10.0.0.77" }

      expect(response).to have_http_status(:ok)
    end

    it "returns 403 and does not update last_used_at for a disallowed IP" do
      get "/api/v1/ping", headers: auth_headers, env: { "REMOTE_ADDR" => "198.51.100.9" }

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to eq("error" => "Forbidden")
      expect(key.reload.last_used_at).to be_nil
    end
  end
end
