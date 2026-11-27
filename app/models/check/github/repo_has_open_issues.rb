# frozen_string_literal: true

class Check::Github::RepoHasOpenIssues < Check
  include Check::Github::RepoCheck

  def default_name
    "#{repo} issues"
  end

  def next_count
    integration.count_open_issues(repo:)
  end

  def url
    "#{integration.web_endpoint}/#{repo}/issues"
  end
end
