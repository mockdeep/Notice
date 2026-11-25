# frozen_string_literal: true

require "rails_helper"

RSpec.describe Target do
  describe "#goal_reached?" do
    it "returns true when the target matches its goal target" do
      expect(described_class.new(value: 3, goal_value: 3)).to be_goal_reached
    end

    it "returns false when the target hasn't reached its goal target" do
      expect(described_class.new(value: 5, goal_value: 3))
        .not_to be_goal_reached
    end
  end
end
