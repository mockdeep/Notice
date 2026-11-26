# frozen_string_literal: true

# A group dropdown for check forms. Hidden when the user has only one
# group, since there's nothing to choose.
class Components::GroupSelect < Components::Base
  def initialize(form:)
    super()
    @form = form
  end

  def view_template
    groups = current_user.groups.order(:name).to_a
    return if groups.size < 2

    div(class: "field") do
      @form.label(:group_id, "Group")
      @form.collection_select(:group_id, groups, :id, :name)
    end
  end
end
