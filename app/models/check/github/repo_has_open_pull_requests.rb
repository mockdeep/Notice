# frozen_string_literal: true

class Check::Github::RepoHasOpenPullRequests < Check
  include Check::Github::RepoCheck

  def next_count
    integration.count_open_pull_requests(repo:)
  end

  def url
    "#{integration.web_endpoint}/#{repo}/pulls"
  end
end
