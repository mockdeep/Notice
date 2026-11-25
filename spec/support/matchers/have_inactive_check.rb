# frozen_string_literal: true

require_relative "have_check"

class Matchers::HaveInactiveCheck < Matchers::HaveCheck
  private

  def name_selector
    ".checks-on-target #{NAME_SELECTOR}"
  end
end
