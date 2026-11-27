# frozen_string_literal: true

require "rails_helper"

RSpec.describe Check::Github::UserHasAssignedPullRequests do
  def fake_implementation
    require Rails.root.join("spec/support/fake_api/github/client")
    existing_class = Integration::Github.client_class
    Integration::Github.client_class = FakeApi::Github::Client

    yield

    Integration::Github.client_class = existing_class
  end

  describe "#next_count" do
    it "returns the count of pull requests" do
      fake_implementation do
        integration = create(:github_integration)
        check = described_class.new(integration:)

        expect(check.next_count).to eq(2)
      end
    end
  end

  describe "#default_name" do
    it "describes what is counted" do
      expect(described_class.new.default_name).to eq("Assigned pull requests")
    end
  end

  describe "#icon" do
    it "returns an array for the icon" do
      expect(described_class.new.icon).to eq(["fab", "github"])
    end
  end
end
