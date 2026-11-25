# frozen_string_literal: true

class Views::Accounts::Show < Views::Base
  CONFIRM = "Are you sure? This cannot be undone."

  def initialize(user:)
    @user = user
  end

  def view_template
    PageHeader(title: "Your account")

    div(class: "form-card") do
      account_form
      delete_button
    end
  end

  private

  def account_form
    form_with(model: @user, url: account_path) do |form|
      ErrorExplanation(model: @user)

      div(class: "field") do
        form.label(:email)
        form.email_field(:email, required: true)
      end

      div(class: "actions") { form.submit("Save changes") }
    end
  end

  def delete_button
    form = { data: { turbo: true, turbo_confirm: CONFIRM } }
    options = { method: :delete, class: "btn-danger", form: }

    div(class: "danger-zone") do
      button_to("Delete account", account_path, **options)
    end
  end
end
