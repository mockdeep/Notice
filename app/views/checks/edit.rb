# frozen_string_literal: true

class Views::Checks::Edit < Views::Base
  def initialize(check:)
    @check = check
  end

  def view_template
    PageHeader(title: "Edit check", subtitle: @check.name)

    div(class: "form-card") do
      edit_form
      delete_button
    end
  end

  private

  def edit_form
    form_with(model: @check) do |form|
      ErrorExplanation(model: @check)

      field(form, :name) { form.text_field(:name, required: true) }

      form.fields_for(:target) { |target_form| target_fields(target_form) }

      div(class: "actions") { form.submit("Save changes") }
    end
  end

  def delete_button
    confirm = "Delete check? #{@check.name}"
    form = { data: { turbo: true, turbo_confirm: confirm } }
    options = { method: :delete, class: "btn-danger", form: }

    div(class: "danger-zone") do
      button_to("Delete check", check_path(@check), **options)
    end
  end

  def target_fields(form)
    field(form, :value, "Target") { form.number_field(:value, required: true) }
    field(form, :delta) { form.number_field(:delta, required: true) }
    field(form, :goal_value, "Goal target") do
      form.number_field(:goal_value, required: true)
    end
  end

  def field(form, name, label = nil)
    div(class: "field") do
      form.label(name, label)
      yield
    end
  end
end
