# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupsController do
  describe "#index" do
    it "lists the user's groups with their check counts" do
      check = create(:check)
      login_as(check.user)

      get(groups_path)

      expect(rendered).to have_text("General").and have_text("1 check")
    end

    it "does not list other users' groups" do
      create(:group, name: "Someone else's")
      login_as(create(:user))

      get(groups_path)

      expect(rendered).to have_no_text("Someone else's")
    end
  end

  describe "#create" do
    it "creates a group" do
      user = create(:user)
      login_as(user)

      expect { post(groups_path, params: { group: { name: "notice" } }) }
        .to change(user.groups, :count).by(1)
    end

    it "redirects to the groups list" do
      login_as(create(:user))

      post(groups_path, params: { group: { name: "notice" } })

      expect(response).to redirect_to(groups_path)
    end

    it "re-renders the form when the name is taken" do
      login_as(create(:user))

      post(groups_path, params: { group: { name: "General" } })

      expect(rendered).to have_text("Name has already been taken")
    end
  end

  describe "#update" do
    it "renames the group" do
      group = create(:group)
      login_as(group.user)

      patch(group_path(group), params: { group: { name: "Renamed" } })

      expect(group.reload.name).to eq("Renamed")
    end

    it "returns not found for another user's group" do
      group = create(:group)
      login_as(create(:user))

      patch(group_path(group), params: { group: { name: "Renamed" } })

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#remove" do
    it "lists the checks that will be deleted" do
      check = create(:check, name: "Open PRs", group: create(:group))
      login_as(check.user)

      get(remove_group_path(check.group))

      expect(rendered).to have_text("Open PRs")
        .and have_button("Permanently delete group and 1 check")
    end

    it "does not offer to delete the last group" do
      user = create(:user)
      login_as(user)

      get(remove_group_path(user.groups.first))

      expect(rendered).to have_no_button("Permanently delete group")
    end
  end

  describe "#destroy" do
    it "deletes the group" do
      group = create(:group)
      login_as(group.user)

      expect { delete(group_path(group)) }.to delete_record(group)
    end

    it "flashes an error for the last group" do
      user = create(:user)
      login_as(user)

      delete(group_path(user.groups.first))

      expect(flash[:error]).to include("need at least one group")
    end
  end
end
