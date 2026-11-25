# frozen_string_literal: true

class Matchers::HaveNoChecks
  attr_accessor :page

  def matches?(page)
    self.page = page
    page.has_no_selector?(check_selector)
  end

  def failure_message
    check_names = page.all("#{check_selector} .check-name").map(&:text)
    "expected page to have no checks, but had: #{check_names}"
  end

  private

  def check_selector
    ".check"
  end
end
