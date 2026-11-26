# frozen_string_literal: true

class Integration::Github < Integration
  validates :access_token, presence: true
  store_accessor :data, :access_token
  delegate(
    :count_assigned_pull_requests,
    :count_open_issues,
    :count_open_pull_requests,
    :repo_exists?,
    to: :client,
  )

  class << self
    attr_writer :client_class
  end

  def self.client_class
    @client_class ||= ::Github::Client
  end

  def self.authorize_url(state:)
    client_class.authorize_url(state:)
  end

  def web_endpoint
    self.class.client_class.web_endpoint
  end

  def code=(code)
    self.access_token = self.class.client_class.exchange_code(code:)
  end

  private

  def client
    @client ||= self.class.client_class.new(access_token:)
  end
end
