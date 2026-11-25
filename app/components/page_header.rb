# frozen_string_literal: true

# The top of a page below the site header: an optional link back to the
# checks list, the page title, and an optional line of explanation.
class Components::PageHeader < Components::Base
  def initialize(title:, subtitle: nil, back: true)
    super()
    @title = title
    @subtitle = subtitle
    @back = back
  end

  def view_template
    div(class: "page-header") do
      back_link if @back
      h1 { @title }
      p(class: "page-subtitle") { @subtitle } if @subtitle
    end
  end

  private

  def back_link
    link_to(checks_path, class: "back-link") do
      Icon("fas", "arrow-left", aria: { hidden: true })
      plain("Back to checks")
    end
  end
end
