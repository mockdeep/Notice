# frozen_string_literal: true

class Views::Checks::Index < Views::Base
  def initialize(checks:, unreached_goal_targets:)
    active_checks, @on_target_checks = checks.partition(&:active?)
    @attention_checks = by_priority(active_checks)
    @unreached_goal_targets = unreached_goal_targets
    @show_groups = checks.map(&:group_id).uniq.many?
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
        by_group(@attention_checks) do |checks|
          div(class: "check-cards") { checks.each { CheckCard(check: it) } }
        end
      else
        all_clear
      end
    end
  end

  def on_target_section
    section(class: "checks-on-target", aria: { labelledby: "on-target" }) do
      section_heading("on-target", "On target", @on_target_checks.count)

      by_group(@on_target_checks) do |checks|
        ul(class: "check-rows") { checks.each { CheckRow(check: it) } }
      end
    end
  end

  # Yields the checks once per group, under a heading, with groups sorted
  # by name. With only one group in play the headings would be noise, so
  # it yields all the checks at once.
  def by_group(checks)
    return yield(checks) unless @show_groups

    groups = checks.group_by(&:group).sort_by { |group, _| group.name.downcase }
    groups.each do |group, group_checks|
      div(class: "check-group") do
        h3(class: "check-group-heading") { group.name }
        yield(group_checks)
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

    p { unreached_goals_message }
    div(class: "all-clear-actions") do
      button_to(
        "Lower all targets",
        target_refreshes_path(checks: "all"),
        remote: false,
        class: "btn-primary",
      )
    end
  end

  def unreached_goals_message
    if @unreached_goal_targets.many?
      count = @unreached_goal_targets.count
      "#{count} checks below haven't reached their goal target yet."
    else
      "1 check below hasn't reached its goal target yet."
    end
  end
end
