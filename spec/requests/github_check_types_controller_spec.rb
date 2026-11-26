# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubCheckTypesController do
  describe "#index" do
    def link_for(integration, check_type)
      path = new_github_integration_check_path(integration, check_type:)
      %(href="#{path}")
    end

    ["assigned_pull_requests", "repo_pull_requests"].each do |check_type|
      it "links to the new check page for #{check_type}" do
        integration = create(:github_integration)
        login_as(integration.user)

        get(github_integration_check_types_path(integration))

        expect(response.body).to include(link_for(integration, check_type))
      end
    end

    it "does not show another user's integration" do
      integration = create(:github_integration)
      login_as(create(:user))

      get(github_integration_check_types_path(integration))

      expect(response).to have_http_status(:not_found)
    end
  end
end
