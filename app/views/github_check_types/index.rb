# frozen_string_literal: true

class Views::GithubCheckTypes::Index < Views::Base
  CHECK_TYPES = [
    {
      key: :assigned_pull_requests,
      icon: ["fas", "user"],
      path: :new_github_integration_check_path,
    },
  ].freeze

  def initialize(integration:)
    super()
    @integration = integration
  end

  def view_template
    PageHeader(title: translate(:title), subtitle: translate(:subtitle))

    div(class: "source-options") do
      CHECK_TYPES.each { |check_type| check_type_option(**check_type) }
    end
  end

  private

  def check_type_option(key:, icon:, path:)
    link_to(public_send(path, @integration), class: "source-option") do
      span(class: "source-option-icon") { Icon(*icon, aria: { hidden: true }) }
      span(class: "source-option-name") { translate(:name, key) }
      span(class: "source-option-about") { translate(:about, key) }
    end
  end

  def translate(key, *nested)
    I18n.t(key, scope: [:views, :github_check_types, :index, *nested])
  end
end
