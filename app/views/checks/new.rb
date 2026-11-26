# frozen_string_literal: true

class Views::Checks::New < Views::Base
  SOURCES = [
    {
      name: "Trello",
      icon: ["fab", "trello"],
      about: "Count the cards in a list.",
      path: :new_trello_integration_path,
    },
    {
      name: "GitHub",
      icon: ["fab", "github"],
      about: "Count pull requests and issues.",
      path: :new_github_integration_path,
    },
    {
      name: "Manual count",
      icon: ["fas", "hashtag"],
      about: "A number you type in yourself.",
      path: :new_manual_integration_path,
    },
  ].freeze

  def view_template
    PageHeader(
      title: "New check",
      subtitle: "What should Notice keep count of?",
    )

    div(class: "source-options") do
      SOURCES.each { |source| source_option(**source) }
    end
  end

  private

  def source_option(name:, icon:, about:, path:)
    link_to(public_send(path), class: "source-option") do
      span(class: "source-option-icon") { Icon(*icon, aria: { hidden: true }) }
      span(class: "source-option-name") { name }
      span(class: "source-option-about") { about }
    end
  end
end
