# frozen_string_literal: true

class Views::Groups::Index < Views::Base
  def initialize(groups:)
    super()
    @groups = groups
  end

  def view_template
    div(class: "page-heading") do
      h1 { "Your groups" }
      link_to(new_group_path, class: "btn-primary") do
        Icon("fas", "plus", aria: { hidden: true })
        plain("New group")
      end
    end

    ul(class: "group-rows") { @groups.each { |group| group_row(group) } }
  end

  private

  def group_row(group)
    li(class: "group-row") do
      span(class: "group-row-name") { group.name }
      span(class: "group-row-count") { pluralize(group.checks.size, "check") }
      link_to(
        "Edit",
        edit_group_path(group),
        class: "btn btn-small",
        aria: { label: "Edit #{group.name}" },
      )
    end
  end
end
