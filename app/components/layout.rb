# frozen_string_literal: true

class Components::Layout < Components::Base
  include Phlex::Rails::Layout

  # The tab icon shows the highest priority among checks over target.
  FAVICON_COLORS = { normal: "yellow", high: "orange", urgent: "red" }.freeze
  HOTKEYS_ACTION = "keydown@document->hotkeys#handleKeydown"
  STYLESHEET_OPTIONS = { media: "all", "data-turbo-track": "reload" }.freeze

  def view_template(&)
    doctype

    html do
      head { head_tags }

      body(data: { controller: "hotkeys", action: HOTKEYS_ACTION }) do
        site_header
        main_content(&)
      end
    end
  end

  private

  def head_tags
    title { "Notice" }
    csrf_meta_tags
    csp_meta_tag
    meta(name: "viewport", content: "width=device-width, initial-scale=1.0")

    stylesheet_link_tag("application", **STYLESHEET_OPTIONS)
    javascript_include_tag("application", "data-turbo-track": "reload")
    favicons
  end

  def favicons
    color = favicon_color

    favicon_link_tag("favicon-#{color}.ico", sizes: "32x32")
    favicon_link_tag("favicon-#{color}.svg", type: "image/svg+xml")
  end

  def favicon_color
    return "grey" unless current_user.logged_in?

    checks = current_user.checks.preload(:latest_count, :target)
    FAVICON_COLORS.fetch(Check.top_priority(checks), "grey")
  end

  def main_content
    main do
      flashes
      yield
    end
  end

  def site_header
    header(class: "site-header") do
      div(class: "site-header-inner") do
        logo
        nav(class: "site-nav", aria: { label: "Account" }) do
          current_user.logged_in? ? logged_in_nav : logged_out_nav
        end
      end
    end
  end

  def logo
    home = current_user.logged_in? ? checks_path : root_path

    link_to(home, class: "wordmark", aria: { label: "Notice" }) do
      image_tag("notice-marker.svg", class: "wordmark-marker", alt: "")
      plain("Notice")
    end
  end

  def logged_in_nav
    span(class: "site-nav-email") { current_user.email }
    link_to("Account", account_path)
    button_to("Log out", session_path, method: :delete)
  end

  def logged_out_nav
    link_to("Log in", new_session_path) unless current_page?(new_session_path)
    return if current_page?(new_account_path)

    link_to("Sign up", new_account_path, class: "btn")
  end

  def flashes
    div(class: "flashes") do
      flash.each do |type, message|
        div(class: "flash-#{type}") { message }
      end
    end
  end
end
