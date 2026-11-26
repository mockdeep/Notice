# frozen_string_literal: true

require "rails_helper"

RSpec.describe User::Destroy do
  it "deletes the user" do
    user = create(:user)

    expect { described_class.call(user) }.to delete_record(user)
  end

  it "deletes the user's checks" do
    check = create(:check, value: 3)

    expect { described_class.call(check.user) }.to delete_record(check)
  end

  it "deletes the user's counts" do
    count = create(:check, value: 3).latest_count

    expect { described_class.call(count.check.user) }.to delete_record(count)
  end

  it "deletes the user's targets" do
    target = create(:target)

    expect { described_class.call(target.user) }.to delete_record(target)
  end

  it "deletes the user's groups" do
    group = create(:group)

    expect { described_class.call(group.user) }.to delete_record(group)
  end

  it "deletes the user's integrations" do
    integration = create(:integration)

    expect { described_class.call(integration.user) }
      .to delete_record(integration)
  end

  it "deletes the user's api keys" do
    api_key = create(:api_key)

    expect { described_class.call(api_key.user) }.to delete_record(api_key)
  end

  it "does not delete other users' checks" do
    check = create(:check, value: 2)

    expect { described_class.call(create(:user)) }.not_to delete_record(check)
  end
end
