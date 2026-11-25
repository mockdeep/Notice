# frozen_string_literal: true

require_relative "have_no_checks"

class Matchers::HaveNoActiveChecks < Matchers::HaveNoChecks
  private

  def check_selector
    ".checks-attention .check"
  end
end
