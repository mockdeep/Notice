# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:checks).dependent(:restrict_with_exception) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:name) }

  it "validates name is unique per user" do
    expect(build(:group)).to validate_uniqueness_of(:name).scoped_to(:user_id)
  end
end
