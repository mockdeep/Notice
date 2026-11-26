# frozen_string_literal: true

class Views::Accounts::Remove < Views::Base
  def initialize(user:)
    super()
    @user = user
  end

  def view_template
    PageHeader(title: "Delete account")

    div(class: "form-card") do
      warning
      actions
    end
  end

  private

  def warning
    p do
      plain("This will permanently delete the account for ")
      strong { @user.email }
      plain(". This cannot be undone.")
    end
  end

  def actions
    options = { method: :delete, class: "btn-danger" }

    div(class: "actions") do
      button_to("Permanently delete account", account_path, **options)
      link_to("Cancel", account_path)
    end
  end
end
