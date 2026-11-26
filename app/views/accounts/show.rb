# frozen_string_literal: true

class Views::Accounts::Show < Views::Base
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
    div(class: "danger-zone") do
      link_to("Delete account", remove_account_path, class: "btn-danger")
    end
  end
end
