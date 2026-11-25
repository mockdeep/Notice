# frozen_string_literal: true

class Github::Client
  WEB_ENDPOINT = "https://github.com"
  API_ENDPOINT = "https://api.github.com"

  attr_accessor :access_token

  def self.client_id
    Rails.configuration.x.github.client_id
  end

  def self.client_secret
    Rails.configuration.x.github.client_secret
  end

  def self.web_endpoint
    WEB_ENDPOINT
  end

  def self.authorize_url(state:)
    params = { client_id:, state: }
    "#{WEB_ENDPOINT}/login/oauth/authorize?#{params.to_query}"
  end

  def self.exchange_code(code:)
    url = "#{WEB_ENDPOINT}/login/oauth/access_token"
    form = { client_id:, client_secret:, code: }
    data = request_json(:post, url, form:)

    data[:access_token] ||
      (raise Github::ApiError, "GitHub token exchange failed: #{data[:error]}")
  end

  def self.request_json(method, url, headers: {}, **)
    response = HTTP.timeout(connect: 5, read: 10)
      .headers(accept: "application/json", **headers)
      .public_send(method, url, **)
    unless response.status.success?
      raise Github::ApiError, "GitHub API error #{response.status.code}"
    end

    JSON.parse(response.body, symbolize_names: true)
  rescue HTTP::Error, JSON::ParserError => e
    raise Github::ApiError, "GitHub request failed: #{e.message}"
  end

  def initialize(access_token:)
    self.access_token = access_token
  end

  def count_assigned_pull_requests
    params = { q: "is:pr is:open assignee:@me", per_page: 1 }
    url = "#{API_ENDPOINT}/search/issues"
    data = self.class.request_json(:get, url, headers: api_headers, params:)

    data[:total_count]
  end

  private

  def api_headers
    {
      accept: "application/vnd.github+json",
      authorization: "Bearer #{access_token}",
      "X-GitHub-Api-Version": "2022-11-28",
    }
  end
end
