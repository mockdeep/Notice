# frozen_string_literal: true

require "rails_helper"

RSpec.describe Integration::Github do
  def fake_implementation
    require Rails.root.join("spec/support/fake_api/github/client")
    existing_class = described_class.client_class
    described_class.client_class = FakeApi::Github::Client
    yield
    described_class.client_class = existing_class
  end

  describe "#code=" do
    it "exchanges the code for an access token" do
      fake_implementation do
        integration = described_class.new(code: "some_code")

        expect(integration.access_token).to eq("some-auth-token")
      end
    end
  end
end
