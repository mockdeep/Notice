# frozen_string_literal: true

# The top of a page below the site header: an optional back link (to the
# checks list unless `back_to` says otherwise), the page title, and an
# optional line of explanation.
class Components::PageHeader < Components::Base
  def initialize(
    title:,
    subtitle: nil,
    back: true,
    back_to: nil,
    back_label: "Back to checks"
  )
    super()
    @title = title
    @subtitle = subtitle
    @back = back
    @back_to = back_to
    @back_label = back_label
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
    link_to(@back_to || checks_path, class: "back-link") do
      Icon("fas", "arrow-left", aria: { hidden: true })
      plain(@back_label)
    end
  end
end
