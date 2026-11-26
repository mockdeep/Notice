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
    raise_for_status(response.status)

    JSON.parse(response.body, symbolize_names: true)
  rescue HTTP::Error, JSON::ParserError => e
    raise Github::ApiError, "GitHub request failed: #{e.message}"
  end

  def initialize(access_token:)
    self.access_token = access_token
  end

  def count_assigned_pull_requests
    count_search_results("is:pr is:open assignee:@me")
  end

  def count_open_pull_requests(repo:)
    count_search_results("repo:#{repo} is:pr is:open")
  end

  def repo_exists?(repo:)
    self.class.request_json(
      :get,
      "#{API_ENDPOINT}/repos/#{repo}",
      headers: api_headers,
    )
    true
  rescue Github::NotFoundError
    false
  end

  def self.raise_for_status(status)
    return if status.success?

    error_class = status.not_found? ? Github::NotFoundError : Github::ApiError
    raise error_class, "GitHub API error #{status.code}"
  end
  private_class_method :raise_for_status

  private

  def count_search_results(query)
    params = { q: query, per_page: 1 }
    url = "#{API_ENDPOINT}/search/issues"
    data = self.class.request_json(:get, url, headers: api_headers, params:)

    data[:total_count]
  end

  def api_headers
    {
      accept: "application/vnd.github+json",
      authorization: "Bearer #{access_token}",
      "X-GitHub-Api-Version": "2022-11-28",
    }
  end
end
