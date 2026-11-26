# frozen_string_literal: true

require "rails_helper"

RSpec.describe ManualChecksController do
  describe "#new" do
    it "renders the new check page" do
      integration = create(:manual_integration)
      login_as(integration.user)

      get(new_manual_integration_check_path(integration))

      expect(rendered).to have_text("Name your check")
    end
  end

  describe "#create" do
    it "creates a new check" do
      integration = create(:manual_integration)
      login_as(integration.user)

      path = manual_integration_checks_path(integration)
      expect { post(path, params: { check: { name: "a new check" } }) }
        .to change(integration.checks, :count).by(1)
    end

    it "puts the check in the first group by default" do
      integration = create(:manual_integration)
      login_as(integration.user)

      path = manual_integration_checks_path(integration)
      post(path, params: { check: { name: "a new check" } })

      expect(Check.last.group).to eq(integration.user.groups.first)
    end

    it "puts the check in the chosen group" do
      group = create(:group)
      login_as(group.user)

      params = { check: { name: "a new check", group_id: group.id } }
      post(manual_integration_checks_path(default_manual_integration), params:)

      expect(Check.last.group).to eq(group)
    end

    it "shows the form again when the name is taken in the group" do
      check = create(:manual_check)
      login_as(check.user)

      params = { check: { name: check.name } }
      post(manual_integration_checks_path(check.integration), params:)

      expect(rendered).to have_text("Name has already been taken")
    end

    it "refreshes the check" do
      integration = create(:manual_integration)
      login_as(integration.user)

      params = { check: { name: "a new check" } }
      path = manual_integration_checks_path(integration)

      expect { post(path, params:) }.to invoke(:call).on(Check::Refresh)
    end

    it "redirects to checks/index" do
      integration = create(:manual_integration)
      login_as(integration.user)

      params = { check: { name: "a new check" } }
      post(manual_integration_checks_path(integration), params:)

      expect(response).to redirect_to(checks_path)
    end
  end
end
