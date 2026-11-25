# frozen_string_literal: true

class Page::Check
  attr_accessor :element

  def self.find(page, check)
    new(page.find(".check", text: check.name))
  end

  def initialize(element)
    self.element = element
  end

  def edit_icon
    element.find(".fa-pen")
  end

  def refresh_icon
    element.find(".fa-sync-alt")
  end
end
