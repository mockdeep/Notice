# frozen_string_literal: true

require_relative "have_no_checks"

class Matchers::HaveNoInactiveChecks < Matchers::HaveNoChecks
  private

  def check_selector
    ".checks-on-target .check"
  end
end
