# frozen_string_literal: true

class Components::CheckNameForm < Components::Base
  def initialize(check:, url:)
    @check = check
    @url = url
  end

  # Yields the form builder so callers can add their own hidden fields.
  def view_template(&block)
    PageHeader(title: "Name your check")

    div(class: "form-card") do
      form_with(model: @check, url: @url) do |form|
        ErrorExplanation(model: @check)
        yield(form) if block
        name_field(form)
        GroupSelect(form:)
        div(class: "actions") { form.submit("Create check") }
      end
    end
  end

  private

  def name_field(form)
    div(class: "field") do
      form.label(:name)
      form.text_field(:name, value: @check.name || @check.default_name)
    end
  end
end
