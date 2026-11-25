# frozen_string_literal: true

class Views::Checks::Index < Views::Base
  def initialize(checks:, unreached_goal_targets:)
    active_checks, @on_target_checks = checks.partition(&:active?)
    @attention_checks = by_priority(active_checks)
    @unreached_goal_targets = unreached_goal_targets
  end

  def view_template
    div(class: "page-heading") do
      h1 { "Your checks" }
      link_to(new_check_path, class: "btn-primary") do
        Icon("fas", "plus", aria: { hidden: true })
        plain("New check")
      end
    end

    attention_section
    on_target_section if @on_target_checks.any?
  end

  private

  # Highest priority first, keeping the existing order within each level.
  def by_priority(checks)
    checks.sort_by.with_index do |check, index|
      [-Check::PRIORITIES.index(check.priority), index]
    end
  end

  def attention_section
    section(class: "checks-attention", aria: { labelledby: "attention" }) do
      section_heading("attention", "Needs attention", @attention_checks.count)

      if @attention_checks.any?
        div(class: "check-cards") do
          @attention_checks.each { |check| CheckCard(check:) }
        end
      else
        all_clear
      end
    end
  end

  def on_target_section
    section(class: "checks-on-target", aria: { labelledby: "on-target" }) do
      section_heading("on-target", "On target", @on_target_checks.count)

      ul(class: "check-rows") do
        @on_target_checks.each { |check| CheckRow(check:) }
      end
    end
  end

  def section_heading(id, text, count)
    h2(id:, class: "section-heading") do
      plain(text)
      span(class: ["section-count", ("section-count-zero" if count.zero?)]) do
        count.to_s
      end
    end
  end

  def all_clear
    div(class: "all-clear") do
      p(class: "all-clear-title") { "All clear! Nothing needs your attention." }
      unreached_goals
    end
  end

  def unreached_goals
    return if @unreached_goal_targets.empty?

    p { "Some checks haven't reached their goal target yet." }
    div(class: "all-clear-actions") do
      refresh_button("Refresh 1 target", "one")
      next unless @unreached_goal_targets.many?

      count = @unreached_goal_targets.count
      refresh_button("Refresh all #{count} targets", "all")
    end
  end

  def refresh_button(label, checks)
    button_to(
      label,
      target_refreshes_path(checks:),
      remote: false,
      class: "btn-primary",
    )
  end
end
