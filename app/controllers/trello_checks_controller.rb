# frozen_string_literal: true

class TrelloChecksController < ApplicationController
  def new
    render(new_view)
  end

  def create
    if check.save
      Check::Refresh.call(check)
      redirect_to(checks_path)
    else
      render(new_view, status: :unprocessable_content)
    end
  end

  private

  def new_view
    Views::TrelloChecks::New.new(check:, integration: trello_integration)
  end

  def check
    @check ||= Check::Trello::ListHasCards.new(check_params)
  end

  def trello_integration
    @trello_integration ||=
      current_user.integrations.find(params.fetch(:trello_integration_id))
  end

  def base_params
    {
      user: current_user,
      integration: trello_integration,
      target_attributes: {},
    }
  end

  def check_params
    check_params =
      if params.key?(:check)
        params.expect(check: [:board_id, :list_id, :name, :group_id])
      else
        {}
      end
    check_params
      .reverse_merge(group_id: current_user.groups.first.id)
      .merge(base_params)
  end
end
