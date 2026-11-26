# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :integrations, dependent: :delete_all
  has_many :checks, dependent: :delete_all
  has_many :targets, through: :checks
  has_many :api_keys, dependent: :delete_all
  # Declared after checks so checks are deleted before their groups.
  has_many :groups, dependent: :delete_all

  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP

  after_create { groups.create!(name: "General") }

  def logged_in?
    true
  end
end
