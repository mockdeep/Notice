# frozen_string_literal: true

class Views::Groups::Edit < Views::Base
  def initialize(group:, last_group:)
    super()
    @group = group
    @last_group = last_group
  end

  def view_template
    PageHeader(
      title: "Edit group",
      subtitle: @group.name_was,
      back_to: groups_path,
      back_label: "Back to groups",
    )

    div(class: "form-card") do
      GroupForm(group: @group, submit: "Save changes")
      delete_link unless @last_group
    end
  end

  private

  def delete_link
    div(class: "danger-zone") do
      link_to("Delete group", remove_group_path(@group), class: "btn-danger")
    end
  end
end
