# frozen_string_literal: true

class Views::GithubIntegrations::New < Views::Base
  def initialize(authorize_url:)
    @authorize_url = authorize_url
  end

  def view_template
    PageHeader(
      title: "Connect GitHub",
      subtitle: "Notice needs your permission to count your pull requests.",
    )

    link_to(@authorize_url, class: "btn-primary") do
      Icon("fab", "github", aria: { hidden: true })
      plain("Connect to GitHub")
    end
  end
end
