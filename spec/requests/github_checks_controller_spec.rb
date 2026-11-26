# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubChecksController do
  around do |example|
    require Rails.root.join("spec/support/fake_api/github/client")
    existing_class = Integration::Github.client_class
    Integration::Github.client_class = FakeApi::Github::Client

    example.run

    Integration::Github.client_class = existing_class
  end

  def integration
    @integration ||= create(:github_integration).tap { login_as(it.user) }
  end

  def get_new(check_type: "repo_pull_requests", **)
    get(new_github_integration_check_path(integration, check_type:, **))
  end

  def create_params
    {
      check_type: "repo_pull_requests",
      check: { repo: "rails/rails", name: "Rails PRs" },
    }
  end

  def post_create
    post(github_integration_checks_path(integration), params: create_params)
  end

  describe "#new" do
    it "shows the repo step for a repo check" do
      get_new

      expect(response.body).to include("Pick a repository")
    end

    it "shows an error when the repo is not found" do
      get_new(check: { repo: "rails/nope" })

      expect(response.body).to include("Repository wasn&#39;t found on GitHub")
    end

    it "shows the name step once the repo is found" do
      get_new(check: { repo: "https://github.com/rails/rails" })

      expect(response.body).to include("Name your check")
    end

    it "carries the cleaned-up repo to the name step" do
      get_new(check: { repo: "https://github.com/rails/rails" })

      expect(response.body).to include(%(value="rails/rails"))
    end

    it "responds with bad request for an unknown check type" do
      get_new(check_type: "nope")

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "#create" do
    it "creates a repo check" do
      expect { post_create }
        .to change(Check::Github::RepoHasOpenPullRequests, :count).by(1)
    end

    it "redirects to the checks list" do
      post_create

      expect(response).to redirect_to(checks_path)
    end
  end
end
