# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Trello integration", :js do
  def trello_email
    Rails.configuration.x.trello.email
  end

  def trello_password
    Rails.configuration.x.trello.password
  end

  def start_new_check
    expect(page).to have_heading("Your checks")
    click_on("New check")

    expect(page).to have_text("What should Notice keep count of?")
  end

  def authenticate_with_trello
    click_on("Trello")

    expect(page).to have_heading("Connect Trello")

    click_on("Connect to Trello")
    click_on("Log in")
    fill_in("user", with: trello_email)
    click_on("Continue")
    fill_in("password", with: trello_password)
    click_on("Log in")
    Capybara.using_wait_time(30) { click_on("Allow") }
  end

  def create_trello_check(board:, list:, name:)
    select_board(board)
    select_list(list)
    input_name(name)

    expect(page).to have_heading("Your checks")
  end

  def select_board(board)
    expect(page).to have_text("Pick a board")

    select(board, from: "Board")
    click_on("Next")
  end

  def select_list(list)
    expect(page).to have_text("Pick a list")

    select(list, from: "List")
    click_on("Next")
  end

  def input_name(name)
    expect(page).to have_text("Name your check")
    fill_in("Name", with: name)
    click_on("Create check")
  end

  it "allows a user to configure a Trello integration" do
    sign_in(default_user)
    start_new_check

    authenticate_with_trello
    create_trello_check(board: "Dev Board", list: "Inbox", name: "Inbox cards")

    expect(page).to have_check("Inbox cards")
  end
end
