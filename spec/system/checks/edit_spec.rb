# frozen_string_literal: true

require "rails_helper"

RSpec.describe "checks/edit", :js do
  def find_check(check)
    Page::Check.find(page, check)
  end

  def update_check(check, **params)
    visit(edit_check_path(check))

    params.each { |field, value| fill_in(field, with: value) }

    click_on("Save changes")
  end

  def move_check(check, to:)
    visit(edit_check_path(check))
    select(to, from: "Group")
    click_on("Save changes")
  end

  def expect_check_to_activate(check)
    yield

    expect { find_check(check).refresh_icon.click }
      .to activate_check(check.name).in(page)
  end

  it "allows editing a check" do
    check = create(:check, value: 5)
    sign_in(default_user)

    expect { update_check(check, Target: 5) }
      .to deactivate_check(check.name).in(page)
  end

  it "allows moving a check to another group" do
    check = create(:check)
    create(:group, name: "notice")
    sign_in(default_user)

    move_check(check, to: "notice")

    expect(page).to have_flash(:success, "Check updated")
  end

  it "hides the group field when there is only one group" do
    check = create(:check)
    sign_in(default_user)

    visit(edit_check_path(check))

    expect(page).to have_field("Name").and have_no_field("Group")
  end

  it "allows deleting a check" do
    check = create(:check)
    sign_in(default_user)

    find_check(check).edit_icon.click
    accept_confirm { click_on("Delete check") }

    expect(page).to have_flash(:success, "Check deleted").and have_no_checks
  end

  it "allows setting a moving target on a check" do
    check = create(:check, value: 5)
    sign_in(default_user)

    Test::Check.next_values << 5 << 5
    update_check(check, Target: 5, Delta: 1, "Goal target": 4)

    expect_check_to_activate(check) { travel(1.day) }
  end
end
