# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  # User::Destroy deletes these, in the order the foreign keys need.
  has_many :integrations, dependent: nil
  has_many :checks, dependent: nil
  has_many :targets, through: :checks
  has_many :api_keys, dependent: nil
  has_many :groups, dependent: nil

  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP

  after_create { groups.create!(name: "General") }

  def logged_in?
    true
  end
end
