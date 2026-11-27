# frozen_string_literal: true

class Check::Github::UserHasAssignedPullRequests < Check
  delegate :count_assigned_pull_requests, to: :integration

  STEPS = ["name"].freeze

  def service
    "GitHub"
  end

  def icon
    ["fab", "github"]
  end

  def default_name
    "Assigned pull requests"
  end

  def next_count
    count_assigned_pull_requests
  end

  def next_step
    STEPS.find { |step| public_send(step).nil? }
  end

  def url
    "#{integration.web_endpoint}/pulls/assigned"
  end
end
