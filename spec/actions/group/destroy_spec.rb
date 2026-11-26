# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group::Destroy do
  it "deletes the group" do
    group = create(:group)

    expect { described_class.call(group) }.to delete_record(group)
  end

  it "deletes the group's checks" do
    check = create(:check, value: 2, group: create(:group))

    expect { described_class.call(check.group) }.to delete_record(check)
  end

  it "does not delete checks in other groups" do
    check = create(:check)

    expect { described_class.call(create(:group)) }.not_to delete_record(check)
  end

  it "refuses to delete the user's last group" do
    group = create(:user).groups.first

    expect { described_class.call(group) }
      .to raise_error(described_class::LastGroupError)
      .and not_delete_record(group)
  end
end
