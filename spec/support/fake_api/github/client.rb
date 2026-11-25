# frozen_string_literal: true

require_relative "../modules"

class FakeApi::Github::Client
  attr_accessor :access_token

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
end
