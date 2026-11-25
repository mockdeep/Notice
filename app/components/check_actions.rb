# frozen_string_literal: true

# The link out to a check's source, plus its icon buttons.
class Components::CheckActions < Components::Base
  def initialize(check:)
    super()
    @check = check
  end

  def view_template
    div(class: "check-actions") do
      source_link
      div(class: "check-buttons") do
        refresh_button
        checklist_link if @check.is_a?(Check::Trello::ListHasCards)
        icon_link("Edit", edit_check_path(@check), "pen")
      end
    end
  end

  private

  def source_link
    if @check.manual?
      link_to("Enter count", @check.url, class: "check-source-link")
    else
      options = { target: :_blank, rel: :noreferrer }

      link_to(@check.url, class: "check-source-link", **options) do
        plain("Open in #{@check.service}")
        whitespace
        Icon("fas", "external-link-alt", aria: { hidden: true })
      end
    end
  end

  def refresh_button
    path = check_path(@check, check: { refresh: true })
    options = { title: "Refresh", aria: { label: "Refresh" } }

    button_to(path, method: :patch, class: "btn-icon", **options) do
      Icon("fas", "sync-alt", aria: { hidden: true })
    end
  end

  def checklist_link
    icon_link("View checklist items", check_path(@check), "tasks")
  end

  def icon_link(label, path, icon)
    options = { class: "btn-icon", title: label, aria: { label: } }

    link_to(path, **options) { Icon("fas", icon, aria: { hidden: true }) }
  end
end
