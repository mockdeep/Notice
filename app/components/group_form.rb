# frozen_string_literal: true

# The name form shared by the new and edit group pages.
class Components::GroupForm < Components::Base
  def initialize(group:, submit:)
    super()
    @group = group
    @submit = submit
  end

  def view_template
    form_with(model: @group) do |form|
      ErrorExplanation(model: @group)

      div(class: "field") do
        form.label(:name)
        form.text_field(:name, required: true)
      end

      div(class: "actions") { form.submit(@submit) }
    end
  end
end
