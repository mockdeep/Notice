# frozen_string_literal: true

# A check that's on target, shown as a row in the "On target" list.
class Components::CheckRow < Components::Base
  def initialize(check:)
    super()
    @check = check
  end

  def view_template
    li(class: ["check", "check-row"]) do
      status_icon
      span(class: "check-row-name") do
        span(class: "check-name") { @check.name }
        span(class: "check-service") { @check.service }
      end
      count
      CheckActions(check: @check)
    end
  end

  private

  def status_icon
    counted = !@check.last_value.nil?
    classes = ["check-row-icon", ("check-row-icon-pending" unless counted)]

    span(class: classes) do
      Icon("fas", counted ? "check" : "minus", aria: { hidden: true })
    end
  end

  def count
    span(class: "check-row-count") do
      if @check.last_value.nil?
        plain("Not counted yet")
      else
        strong { @check.last_value.to_s }
        plain(" of #{@check.target_value}")
      end
    end
  end
end
