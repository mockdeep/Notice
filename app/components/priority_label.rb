# frozen_string_literal: true

# The "! Over target" pill on a check card. The number of "!" marks and the
# color both come from the check's priority.
class Components::PriorityLabel < Components::Base
  LABELS = {
    normal: ["!", "Over target"],
    high: ["!!", "High priority"],
    urgent: ["!!!", "Urgent"],
  }.freeze

  def initialize(priority:)
    super()
    @priority = priority
  end

  def view_template
    marks, text = LABELS[@priority]

    span(class: "priority-label") do
      span(class: "priority-marks", aria: { hidden: true }) { marks }
      plain(text)
    end
  end
end
