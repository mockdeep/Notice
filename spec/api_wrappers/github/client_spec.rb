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

  describe "#count_open_pull_requests" do
    it "returns the total count of open pull requests in the repo" do
      query = { q: "repo:rails/rails is:pr is:open", per_page: 1 }.to_query
      stub_request(:get, "https://api.github.com/search/issues?#{query}")
        .to_return(body: { total_count: 7, items: [] }.to_json)

      expect(client.count_open_pull_requests(repo: "rails/rails")).to eq(7)
    end
  end

  describe "#count_open_issues" do
    it "returns the total count of open issues in the repo" do
      query = { q: "repo:rails/rails is:issue is:open", per_page: 1 }.to_query
      stub_request(:get, "https://api.github.com/search/issues?#{query}")
        .to_return(body: { total_count: 9, items: [] }.to_json)

      expect(client.count_open_issues(repo: "rails/rails")).to eq(9)
    end
  end

  describe "#repo_exists?" do
    def repo_url
      "https://api.github.com/repos/rails/rails"
    end

    it "returns true when GitHub finds the repo" do
      stub_request(:get, repo_url)
        .with(headers: { "Authorization" => "Bearer blah" })
        .to_return(body: { full_name: "rails/rails" }.to_json)

      expect(client.repo_exists?(repo: "rails/rails")).to be(true)
    end

    it "returns false when GitHub returns 404" do
      stub_request(:get, repo_url).to_return(status: 404, body: "{}")

      expect(client.repo_exists?(repo: "rails/rails")).to be(false)
    end

    it "raises Github::ApiError on other errors" do
      stub_request(:get, repo_url).to_return(status: 500, body: "")

      expect { client.repo_exists?(repo: "rails/rails") }
        .to raise_error(Github::ApiError)
    end
  end
end
