# frozen_string_literal: true

class Views::Accounts::New < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div(class: "auth-card") do
      h1 { "Create your account" }

      form_with(model: @user, url: account_path) do |form|
        ErrorExplanation(model: @user)
        fields(form)
        div(class: "actions") { form.submit("Create account") }
      end
    end
  end

  private

  def fields(form)
    field(form, :email) { form.email_field(:email, required: true) }
    field(form, :password) { form.password_field(:password, required: true) }
    field(form, :password_confirmation) do
      form.password_field(:password_confirmation, required: true)
    end
  end

  def field(form, name)
    div(class: "field") do
      form.label(name)
      yield
    end
  end
end
