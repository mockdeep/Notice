# frozen_string_literal: true

# A check that's over its target, shown as a card in "Needs attention".
class Components::CheckCard < Components::Base
  def initialize(check:)
    super()
    @check = check
  end

  def view_template
    article(class: ["check", "check-card", "priority-#{@check.priority}"]) do
      div(class: "check-card-top") do
        service
        PriorityLabel(priority: @check.priority)
      end
      h3(class: "check-name") { @check.name }
      count
      CheckActions(check: @check)
    end
  end

  private

  def service
    span(class: "check-service") do
      Icon(*@check.icon, aria: { hidden: true })
      plain(@check.service)
    end
  end

  def count
    value = @check.last_value
    target = @check.target_value

    div(class: "check-count") do
      p(class: "check-count-numbers") do
        span(class: "check-count-value") { value.to_s }
        plain(" of #{target} target")
      end
      progress_bar(value, target)
      p(class: "check-count-over") { "#{value - target} over target" }
    end
  end

  # The whole bar is the current count. The tick marks the target, and the
  # colored part after it is how far over target the check is.
  def progress_bar(value, target)
    target_at = (Float(target) / value * 100).clamp(0, 100).round(1)
    label = "#{value} against a target of #{target}"

    div(
      class: "check-bar",
      role: "img",
      aria: { label: },
      style: "--target-at: #{target_at}%",
    )
  end
end
