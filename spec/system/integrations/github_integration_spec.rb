# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GitHub integration", :js do
  def github_email
    Rails.configuration.x.github.email
  end

  def github_password
    Rails.configuration.x.github.password
  end

  def start_new_check
    expect(page).to have_heading("Your checks")
    click_on("New check")

    expect(page).to have_text("What should Notice keep count of?")
  end

  def authenticate_with_github
    click_on("GitHub")

    expect(page).to have_heading("Connect GitHub")

    click_on("Connect to GitHub")
    fill_in("Username or email", with: github_email)
    fill_in("Password", with: github_password)
    click_on("Sign in")
  end

  def create_github_check(name:)
    choose_check_type("PRs assigned to me")
    input_name(name)

    expect(page).to have_heading("Your checks")
  end

  def choose_check_type(type)
    # wait to allow time to copy/paste email verification code if necessary
    wait_time = FakeApis.enabled? ? Capybara.default_max_wait_time : 10.minutes
    expect(page).to have_text("New GitHub check", wait: wait_time)
    click_on(type)
  end

  def start_github_check(type)
    start_new_check
    authenticate_with_github
    choose_check_type(type)
  end

  def input_repo(repo)
    expect(page).to have_heading("Pick a repository")
    fill_in("Repository", with: repo)
    click_on("Next")
  end

  def input_name(name)
    expect(page).to have_text("Name your check")
    fill_in("Name", with: name)
    click_on("Create check")
  end

  it "allows a user to add a check for PRs assigned to them" do
    sign_in(default_user)
    start_new_check

    authenticate_with_github
    create_github_check(name: "Pulls for Me")

    expect(page).to have_check("Pulls for Me")
  end

  it "allows a user to add a check for open PRs in a repo" do
    sign_in(default_user)
    start_github_check("Open PRs in a repo")
    input_repo("https://github.com/rails/rails")
    input_name("Rails PRs")

    expect(page).to have_check("Rails PRs")
  end

  it "allows a user to add a check for open issues in a repo" do
    sign_in(default_user)
    start_github_check("Open issues in a repo")
    input_repo("rails/rails")
    input_name("Rails issues")

    expect(page).to have_check("Rails issues")
  end

  it "shows an error when the repo is not found" do
    sign_in(default_user)
    start_github_check("Open PRs in a repo")
    input_repo("rails/nope")

    expect(page).to have_text("Repository wasn't found on GitHub")
  end
end
