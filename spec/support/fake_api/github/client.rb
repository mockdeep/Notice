# frozen_string_literal: true

require_relative "../modules"

class FakeApi::Github::Client
  attr_accessor :access_token

  KNOWN_REPOS = ["rails/rails"].freeze

  def self.web_endpoint
    "/github"
  end

  def self.authorize_url(state:)
    "#{web_endpoint}/login/oauth/authorize?state=#{state}"
  end

  def self.exchange_code(**)
    "some-auth-token"
  end

  def initialize(access_token:)
    self.access_token = access_token
  end

  def count_assigned_pull_requests
    2
  end

  def count_open_pull_requests(repo:)
    KNOWN_REPOS.include?(repo) ? 3 : 0
  end

  def repo_exists?(repo:)
    KNOWN_REPOS.include?(repo)
  end
end
