# frozen_string_literal: true

require "rails_helper"

RSpec.describe "check_counts/new", :js do
  def user_creates_count
    click_on("Enter count")

    fill_in("Count", with: 10)

    click_on("Save count")
  end

  it "allows creating new check counts" do
    check = create(:manual_check)
    sign_in(default_user)

    expect { user_creates_count }.to activate_check(check.name).in(page)
  end
end
