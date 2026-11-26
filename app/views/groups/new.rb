# frozen_string_literal: true

class Views::Groups::New < Views::Base
  def initialize(group:)
    super()
    @group = group
  end

  def view_template
    PageHeader(
      title: "New group",
      back_to: groups_path,
      back_label: "Back to groups",
    )

    div(class: "form-card") { GroupForm(group: @group, submit: "Create group") }
  end
end
