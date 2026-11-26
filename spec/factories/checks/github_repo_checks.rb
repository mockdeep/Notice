# frozen_string_literal: true

FactoryBot.define do
  factory(
    :github_repo_pull_requests_check,
    class: "Check::Github::RepoHasOpenPullRequests",
    parent: :check,
  ) do
    integration { association(:github_integration) }
    repo { "rails/rails" }
  end

  factory(
    :github_repo_issues_check,
    class: "Check::Github::RepoHasOpenIssues",
    parent: :check,
  ) do
    integration { association(:github_integration) }
    repo { "rails/rails" }
  end
end
