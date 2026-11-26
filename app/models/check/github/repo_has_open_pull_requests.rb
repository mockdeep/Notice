# frozen_string_literal: true

class Check::Github::RepoHasOpenPullRequests < Check
  REPO_FORMAT = %r{\A[\w.-]+/[\w.-]+\z}
  GITHUB_URL_PREFIX = %r{\A(https?://)?(www\.)?github\.com/}i

  STEPS = ["repo", "name"].freeze

  store_accessor :data, :repo
  # Only look the repo up when it's set, so refreshes don't call GitHub
  # twice or fail if the repo later goes away.
  validate :repo_must_exist, if: -> { new_record? || repo_changed? }

  def service
    "GitHub"
  end

  def icon
    ["fab", "github"]
  end

  # Accepts "owner/name" or a GitHub URL such as
  # "https://github.com/owner/name/pulls".
  def repo=(value)
    @repo_found = nil
    super(normalize_repo(value))
  end

  def next_count
    integration.count_open_pull_requests(repo:)
  end

  def next_step
    return "repo" if repo.nil? || !repo_ready?

    "name" if name.nil?
  end

  def url
    "#{integration.web_endpoint}/#{repo}/pulls"
  end

  private

  def normalize_repo(value)
    return if value.nil?

    path = value.strip.sub(GITHUB_URL_PREFIX, "")
    path.split("/").first(2).join("/").delete_suffix(".git")
  end

  def repo_ready?
    errors.delete(:repo)
    repo_must_exist
    errors[:repo].empty?
  end

  def repo_must_exist
    if repo.blank?
      errors.add(:repo, :blank)
    elsif !repo.match?(REPO_FORMAT)
      errors.add(:repo, :invalid)
    elsif !repo_found?
      errors.add(:repo, :not_found)
    end
  end

  def repo_found?
    @repo_found = integration.repo_exists?(repo:) if @repo_found.nil?
    @repo_found
  end
end
