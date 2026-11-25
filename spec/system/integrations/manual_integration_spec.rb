# frozen_string_literal: true

require "rails_helper"

RSpec.describe "manual integration", :js do
  def start_new_check
    expect(page).to have_heading("Your checks")
    click_on("New check")

    expect(page).to have_text("What should Notice keep count of?")
  end

  def create_manual_check(name:)
    click_on("Manual count")
    expect(page).to have_text("Name your check")
    fill_in("Name", with: name)
    click_on("Create check")
    expect(page).to have_heading("Your checks")
  end

  it "allows a user to configure a manual integration" do
    sign_in(default_user)
    start_new_check
    create_manual_check(name: "Dishes in sink")

    expect(page).to have_inactive_check("Dishes in sink")
  end
end
