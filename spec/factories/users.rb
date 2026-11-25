# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:email, 100) { |n| "demo-#{n}@example.com" }
    password { "super-secure" }
    password_confirmation { "super-secure" }
  end
end
