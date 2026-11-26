# frozen_string_literal: true

class Views::Groups::Remove < Views::Base
  def initialize(group:, checks:, last_group:)
    super()
    @group = group
    @checks = checks
    @last_group = last_group
  end

  def view_template
    PageHeader(
      title: "Delete group",
      back_to: groups_path,
      back_label: "Back to groups",
    )

    div(class: "form-card") do
      @last_group ? last_group_message : confirmation
    end
  end

  private

  def last_group_message
    p do
      strong { @group.name }
      plain(" is your only group. You need at least one, so it can't be ")
      plain("deleted.")
    end

    div(class: "actions") { link_to("Back to groups", groups_path) }
  end

  def confirmation
    warning
    check_list if @checks.any?
    actions
  end

  def warning
    p do
      plain("This will permanently delete the group ")
      strong { @group.name }
      plain(" and the checks below") if @checks.any?
      plain(". This cannot be undone.")
    end
  end

  def check_list
    ul(class: "remove-list") do
      @checks.each { |check| li { check.name } }
    end
  end

  def actions
    options = { method: :delete, class: "btn-danger" }

    div(class: "actions") do
      button_to(button_label, group_path(@group), **options)
      link_to("Cancel", edit_group_path(@group))
    end
  end

  def button_label
    return "Permanently delete group" if @checks.none?

    "Permanently delete group and #{pluralize(@checks.size, "check")}"
  end
end
