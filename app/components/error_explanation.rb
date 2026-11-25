# frozen_string_literal: true

class Components::ErrorExplanation < Components::Base
  def initialize(model:)
    @model = model
  end

  def view_template
    return if @model.errors.empty?

    div(class: "error-explanation") do
      h2 { "Please fix #{pluralize(@model.errors.count, "problem")}:" }
      ul do
        @model.errors.full_messages.each { |message| li { message } }
      end
    end
  end
end
