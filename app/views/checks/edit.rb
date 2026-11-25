# frozen_string_literal: true

class Views::Checks::Edit < Views::Base
  TARGET_HINTS = {
    value: "Notice flags this check when the count goes over this number.",
    delta: "The target drops by this much each day until it reaches the " \
           "goal target. Use 0 to keep it fixed.",
    goal_value: "The target won't drop below this.",
  }.freeze
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
    target_field(form, :value, "Target")
    target_field(form, :delta, "Delta")
    target_field(form, :goal_value, "Goal target")
  end

  def target_field(form, name, label)
    hint_id = "#{form.field_id(name)}_hint"

    field(form, name, label) do
      form.number_field(name, required: true, aria: { describedby: hint_id })
      p(id: hint_id, class: "field-hint") { TARGET_HINTS[name] }
    end
  end

  def field(form, name, label = nil)
    div(class: "field") do
      form.label(name, label)
      yield
    end
  end
end
