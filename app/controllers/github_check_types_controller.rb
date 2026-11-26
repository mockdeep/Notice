# frozen_string_literal: true

class GithubCheckTypesController < ApplicationController
  def index
    render(Views::GithubCheckTypes::Index.new(integration:))
  end

  private

  def integration
    current_user.integrations.github.find(params.expect(:github_integration_id))
  end
end
