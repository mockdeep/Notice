# frozen_string_literal: true

require "rails_helper"

RSpec.describe "groups" do
  def create_group(name)
    click_on("Groups")
    click_on("New group")
    fill_in("Name", with: name)
    click_on("Create group")
  end

  def rename_group(name, to:)
    click_on("Edit #{name}")
    fill_in("Name", with: to)
    click_on("Save changes")
  end

  def delete_group(name)
    click_on("Edit #{name}")
    click_on("Delete group")
    click_on("Permanently delete group")
  end

  it "allows a user to create a group" do
    sign_in(create(:user))

    create_group("notice")

    expect(page).to have_flash(:success, "Group created")
      .and have_text("notice")
  end

  it "allows a user to rename a group" do
    sign_in(create(:user))
    create_group("notice")

    rename_group("notice", to: "notice app")

    expect(page).to have_flash(:success, "Group updated")
      .and have_text("notice app")
  end

  it "allows a user to delete a group" do
    sign_in(create(:user))
    create_group("notice")

    delete_group("notice")

    expect(page).to have_flash(:success, "Group deleted")
      .and have_no_text("notice")
  end

  it "does not allow deleting the last group" do
    sign_in(create(:user))

    click_on("Groups")
    click_on("Edit General")

    expect(page).to have_no_link("Delete group")
  end
end
