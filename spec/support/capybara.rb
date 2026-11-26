# frozen_string_literal: true

require "capybara/rails"
require "capybara-screenshot/rspec"

require_relative "capybara/rack_test"

Capybara.enable_aria_label = true
Capybara.save_path = ENV.fetch("CIRCLE_ARTIFACTS", Capybara.save_path)
Capybara.server = :puma, { Silent: true }

browser = ENV.fetch("DRIVER", :headless_firefox).to_sym

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:selenium, using: browser)
  end

  config.before(:each, type: :controller) do
    Capybara.default_normalize_ws = true
  end

  config.after(:each, type: :controller) do
    Capybara.default_normalize_ws = false
  end
end
