# frozen_string_literal: true

require "rails_helper"

RSpec.describe Check::Github::RepoHasOpenPullRequests do
  around do |example|
    require Rails.root.join("spec/support/fake_api/github/client")
    existing_class = Integration::Github.client_class
    Integration::Github.client_class = FakeApi::Github::Client

    example.run

    Integration::Github.client_class = existing_class
  end

  def build_check(**)
    described_class.new(integration: create(:github_integration), **)
  end

  def create_check
    create(:github_repo_pull_requests_check)
  end

  it_behaves_like "a GitHub repo check"

  describe "#next_count" do
    it "returns the count of open pull requests" do
      expect(build_check(repo: "rails/rails").next_count).to eq(3)
    end
  end

  describe "#default_name" do
    it "names the repo's pull requests" do
      check = build_check(repo: "rails/rails")

      expect(check.default_name).to eq("rails/rails pull requests")
    end
  end

  describe "#url" do
    it "links to the repo's pull requests" do
      check = build_check(repo: "rails/rails")

      expect(check.url).to eq("/github/rails/rails/pulls")
    end
  end
end
