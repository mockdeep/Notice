# frozen_string_literal: true

class GithubChecksController < ApplicationController
  CHECK_CLASSES = {
    "assigned_pull_requests" => Check::Github::UserHasAssignedPullRequests,
    "repo_pull_requests" => Check::Github::RepoHasOpenPullRequests,
    "repo_issues" => Check::Github::RepoHasOpenIssues,
  }.freeze

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
    Views::GithubChecks::New.new(check:, integration:, check_type:)
  end

  def check
    @check ||= check_class.new(check_params)
  end

  def check_type
    params.expect(:check_type)
  end

  def check_class
    CHECK_CLASSES[check_type] || (raise ActionController::BadRequest)
  end

  def integration
    @integration ||= current_user.integrations.github.find(integration_id)
  end

  def integration_id
    params.expect(:github_integration_id)
  end

  def base_params
    {
      user: current_user,
      integration:,
      target_attributes: {},
    }
  end

  def check_params
    check_params =
      if params.key?(:check)
        params.expect(check: [*check_class::STEPS, :group_id])
      else
        {}
      end
    check_params
      .reverse_merge(group_id: current_user.groups.first.id)
      .merge(base_params)
  end
end
