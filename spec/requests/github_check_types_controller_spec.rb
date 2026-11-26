# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubCheckTypesController do
  describe "#index" do
    it "links to the new check page for each check type" do
      integration = create(:github_integration)
      login_as(integration.user)

      get(github_integration_check_types_path(integration))

      path = new_github_integration_check_path(integration)
      expect(response.body).to include(%(href="#{path}"))
    end

    it "does not show another user's integration" do
      integration = create(:github_integration)
      login_as(create(:user))

      get(github_integration_check_types_path(integration))

      expect(response).to have_http_status(:not_found)
    end
  end
end
