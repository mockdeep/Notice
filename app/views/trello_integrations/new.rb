# frozen_string_literal: true

class Views::TrelloIntegrations::New < Views::Base
  def initialize(authorize_url:)
    @authorize_url = authorize_url
  end

  def view_template
    PageHeader(
      title: "Connect Trello",
      subtitle: "Notice needs your permission to count cards in your lists.",
    )

    link_to(@authorize_url, class: "btn-primary") do
      Icon("fab", "trello", aria: { hidden: true })
      plain("Connect to Trello")
    end
  end
end
