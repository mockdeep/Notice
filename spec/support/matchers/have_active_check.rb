# frozen_string_literal: true

require_relative "have_check"

class Matchers::HaveActiveCheck < Matchers::HaveCheck
  private

  def name_selector
    ".checks-attention #{NAME_SELECTOR}"
  end
end
