# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChecksController do
  describe "#index" do
    it "renders the checks page" do
      login_as(create(:user))

      get(:index)

      expect(rendered).to have_text("Your checks")
    end

    it "shows group headings sorted by name" do
      create(:check, group: create(:group, name: "zebra"))
      create(:check, group: create(:group, name: "apple"))
      login_as(default_user)

      get(:index)

      expect(group_headings).to eq([[], ["apple", "zebra"]])
    end

    it "only shows a group in the sections where it has checks" do
      create(:check, value: 1, group: create(:group, name: "zebra"))
      create(:check)
      login_as(default_user)

      get(:index)

      expect(group_headings).to eq([["zebra"], ["General"]])
    end

    it "does not show group headings when all checks share a group" do
      create(:check)
      create(:group)
      login_as(default_user)

      get(:index)

      expect(rendered).to have_no_css(".check-group-heading")
    end

    def group_headings
      [".checks-attention", ".checks-on-target"].map do |section|
        rendered.all("#{section} .check-group-heading").map(&:text)
      end
    end
  end

  it "displays Lower all targets when targets have unreached goal" do
    create_pair(:check, value: 3, target_value: 5, target_delta: 5)
    login_as(default_user)

    get(:index)

    expect(rendered).to have_button("Lower all targets")
      .and have_text("2 checks below haven't reached their goal target yet.")
  end

  it "displays Lower target on checks that haven't reached their goal" do
    check = create(:check, value: 3, target_value: 5, target_delta: 5)
    login_as(default_user)

    get(:index)

    expect(rendered).to have_button("Lower target for #{check.name}")
      .and have_text("goal 0")
  end

  it "does not display Lower buttons when all targets match goal" do
    check = create(:check, value: 0)
    login_as(default_user)

    get(:index)

    expect(rendered).to have_no_button("Lower all targets")
      .and have_no_button("Lower target for #{check.name}")
  end

  describe "#show" do
    def trello_check
      integration = create(:trello_integration)
      Check::Trello::ListHasCards.create!(
        integration:,
        name: "My Check",
        board_id: "b1",
        list_id: "l1",
        user: integration.user,
        group: integration.user.groups.first,
        target_attributes: { value: 0, delta: 0 },
      )
    end

    it "renders the checklist view for Trello checks" do
      check = trello_check
      login_as(check.user)
      stub_request(:get, /trello\.com.*cards/).to_return(body: [].to_json)
      get(:show, params: { id: check.id })
      expect(rendered).to have_text(check.name)
    end

    context "with a non-Trello check" do
      before do
        login_as(default_user)
        get(:show, params: { id: create(:check).id })
      end

      it { expect(response).to redirect_to(checks_path) }

      it "shows a Trello-specific alert" do
        msg = "Details view is only available for Trello checks"
        expect(flash[:alert]).to eq(msg)
      end
    end

    context "when Trello API fails" do
      before do
        check = trello_check
        login_as(check.user)
        stub_request(:get, /trello\.com.*cards/)
          .to_return(status: 500, body: "error")
        get(:show, params: { id: check.id })
      end

      it { expect(response).to redirect_to(checks_path) }
      it { expect(flash[:alert]).to include("Could not load Trello cards") }
    end
  end

  describe "#update_checklist_item" do
    def trello_check
      integration = create(:trello_integration)
      Check::Trello::ListHasCards.create!(
        integration:,
        name: "My Check",
        board_id: "b1",
        list_id: "l1",
        user: integration.user,
        group: integration.user.groups.first,
        target_attributes: { value: 0, delta: 0 },
      )
    end

    def item_params
      { cardId: "c1", itemId: "i1", state: "complete" }
    end

    def update_url_pattern
      %r{api\.trello\.com.*cards/c1/checkItem/i1}
    end

    def bad_state_params(check)
      { id: check.id, cardId: "c1", itemId: "i1", state: "bad" }
    end

    def stub_put_api_failure
      stub_request(:put, update_url_pattern)
        .to_return(status: 500, body: "error")
    end

    it "returns ok for Trello checks" do
      check = trello_check
      login_as(check.user)
      stub_request(:put, update_url_pattern).to_return(body: {}.to_json)
      put(:update_checklist_item, params: { id: check.id, **item_params })
      expect(response).to have_http_status(:ok)
    end

    it "returns unprocessable_content for non-Trello checks" do
      check = create(:check)
      login_as(default_user)
      put(:update_checklist_item, params: { id: check.id, **item_params })
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns unprocessable_content for an invalid state" do
      check = trello_check
      login_as(check.user)
      put(:update_checklist_item, params: bad_state_params(check))
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns service_unavailable when Trello API fails" do
      check = trello_check
      login_as(check.user)
      stub_put_api_failure
      put(:update_checklist_item, params: { id: check.id, **item_params })
      expect(response).to have_http_status(:service_unavailable)
    end
  end

  describe "#edit" do
    it "renders the edit page for a check" do
      check = create(:check)
      login_as(default_user)

      get(:edit, params: { id: check.id })

      expect(rendered).to have_text("Edit check").and have_text(check.name)
    end
  end

  describe "#update" do
    context "when params are valid" do
      it "updates the check" do
        check = create(:check)
        login_as(default_user)

        check_params = { target_attributes: { value: 5 } }
        expect { put(:update, params: { id: check.id, check: check_params }) }
          .to change_record(check.target, :value).from(0).to(5)
      end

      it "redirects to checks/index" do
        check = create(:check)
        login_as(default_user)

        check_params = { target_attributes: { value: 5 } }
        put(:update, params: { id: check.id, check: check_params })

        expect(response).to redirect_to(checks_path)
      end

      it "moves the check to another group" do
        check = create(:check)
        group = create(:group)
        login_as(default_user)

        params = { id: check.id, check: { group_id: group.id } }
        expect { put(:update, params:) }.to change_record(check, :group_id)
      end
    end

    context "when moving the check to another user's group" do
      it "does not move the check" do
        check = create(:check)
        group = create(:group, user: create(:user))
        login_as(default_user)

        params = { id: check.id, check: { group_id: group.id } }
        expect { put(:update, params:) }.not_to change_record(check, :group_id)
      end

      it "flashes a success message" do
        check = create(:check)
        login_as(default_user)

        check_params = { target_attributes: { value: 5 } }
        put(:update, params: { id: check.id, check: check_params })

        expect(flash[:success]).to eq("Check updated")
      end
    end

    context "when params are invalid" do
      it "flashes an error message" do
        check = create(:check)
        login_as(default_user)

        check_params = { target_attributes: { value: "" } }
        put(:update, params: { id: check.id, check: check_params })

        expect(response.body).to include("Unable to update check")
      end

      it "renders the edit view" do
        check = create(:check)
        login_as(default_user)

        check_params = { target_attributes: { value: "" } }
        put(:update, params: { id: check.id, check: check_params })

        expect(rendered).to have_text("Edit check").and have_text(check.name)
      end
    end
  end

  describe "#destroy" do
    it "deletes the check" do
      check = create(:check)
      login_as(default_user)

      delete(:destroy, params: { id: check.id })

      expect(Check.find_by(id: check.id)).to be_nil
    end

    it "deletes associated records" do
      check = create(:check, value: 5)
      login_as(default_user)

      delete(:destroy, params: { id: check.id })

      expect(Count.where(check_id: check.id)).to be_empty
    end

    it "flashes a success message" do
      check = create(:check)
      login_as(default_user)

      delete(:destroy, params: { id: check.id })

      expect(flash[:success]).to eq("Check deleted")
    end

    it "redirects to checks/index" do
      check = create(:check)
      login_as(default_user)

      delete(:destroy, params: { id: check.id })

      expect(response).to redirect_to(checks_path)
    end

    it "raises an error when user cannot access check" do
      check = create(:check)
      login_as(create(:user))

      expect { delete(:destroy, params: { id: check.id }) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
