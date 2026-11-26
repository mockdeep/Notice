# frozen_string_literal: true

require "rails_helper"

RSpec.describe Check::Github::RepoHasOpenIssues do
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
    create(:github_repo_issues_check)
  end

  it_behaves_like "a GitHub repo check"

  describe "#next_count" do
    it "returns the count of open issues" do
      expect(build_check(repo: "rails/rails").next_count).to eq(5)
    end
  end

  describe "#url" do
    it "links to the repo's issues" do
      check = build_check(repo: "rails/rails")

      expect(check.url).to eq("/github/rails/rails/issues")
    end
  end
end
