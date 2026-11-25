# frozen_string_literal: true

require "rails_helper"

RSpec.describe Github::Client do
  delegate :client_id, :client_secret, to: :described_class

  def token_url
    "https://github.com/login/oauth/access_token"
  end

  def search_url
    query = { q: "is:pr is:open assignee:@me", per_page: 1 }.to_query
    "https://api.github.com/search/issues?#{query}"
  end

  def client
    described_class.new(access_token: "blah")
  end

  describe ".authorize_url" do
    it "returns a URL to authorize GitHub access" do
      result = described_class.authorize_url(state: "abc")

      params = { client_id:, state: "abc" }.to_query
      expected = "https://github.com/login/oauth/authorize?#{params}"
      expect(result).to eq(expected)
    end
  end

  describe ".exchange_code" do
    it "returns the access token" do
      stub_request(:post, token_url)
        .with(body: { client_id:, client_secret:, code: "c1" })
        .to_return(body: { access_token: "tok" }.to_json)

      expect(described_class.exchange_code(code: "c1")).to eq("tok")
    end

    it "raises Github::ApiError when GitHub returns an error" do
      stub_request(:post, token_url)
        .to_return(body: { error: "bad_verification_code" }.to_json)

      expect { described_class.exchange_code(code: "c1") }
        .to raise_error(Github::ApiError, /bad_verification_code/)
    end
  end

  describe "#count_assigned_pull_requests" do
    it "returns the total count from the search API" do
      stub_request(:get, search_url)
        .with(headers: { "Authorization" => "Bearer blah" })
        .to_return(body: { total_count: 42, items: [] }.to_json)

      expect(client.count_assigned_pull_requests).to eq(42)
    end

    it "raises Github::ApiError on non-2xx response" do
      stub_request(:get, search_url)
        .to_return(status: 401, body: "Unauthorized")

      expect { client.count_assigned_pull_requests }
        .to raise_error(Github::ApiError)
    end

    it "raises Github::ApiError on network failure" do
      stub_request(:get, search_url).to_raise(HTTP::ConnectionError)

      expect { client.count_assigned_pull_requests }
        .to raise_error(Github::ApiError)
    end
  end
end
