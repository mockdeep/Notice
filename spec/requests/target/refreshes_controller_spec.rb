# frozen_string_literal: true

require "rails_helper"

RSpec.describe Target::RefreshesController do
  describe "#create" do
    context "when checks: 'all'" do
      it "refreshes all unreached goal targets" do
        target = create(:target, value: 5, delta: 5)
        login_as(target.user)

        expect { post(target_refreshes_path(checks: "all")) }
          .to change_record(target, :value).from(5).to(0)
      end

      it "does not refresh targets that match their goal" do
        target = create(:target, value: 5, goal_value: 5, delta: 5)
        login_as(target.user)

        expect { post(target_refreshes_path(checks: "all")) }
          .to not_change_record(target, :value).from(5)
      end

      it "redirects to checks/index" do
        login_as(create(:user))

        post(target_refreshes_path(checks: "all"))

        expect(response).to redirect_to(checks_path)
      end
    end

    context "when given a target_id" do
      it "lowers that target" do
        target = create(:target, value: 5, delta: 5)
        login_as(target.user)

        expect { post(target_refreshes_path(target_id: target.id)) }
          .to change_record(target, :value).from(5).to(0)
      end

      it "does not lower other targets" do
        target, other_target = create_pair(:target, value: 5, delta: 5)
        login_as(target.user)

        expect { post(target_refreshes_path(target_id: target.id)) }
          .to not_change_record(other_target, :value).from(5)
      end

      it "does not lower a target that matches its goal" do
        target = create(:target, value: 5, goal_value: 5, delta: 5)
        login_as(target.user)

        expect { post(target_refreshes_path(target_id: target.id)) }
          .to not_change_record(target, :value).from(5)
      end

      it "does not lower another user's target" do
        target = create(:target, value: 5, delta: 5)
        login_as(create(:user))

        expect { post(target_refreshes_path(target_id: target.id)) }
          .to not_change_record(target, :value).from(5)
      end

      it "returns not found for another user's target" do
        target = create(:target, value: 5, delta: 5)
        login_as(create(:user))

        post(target_refreshes_path(target_id: target.id))

        expect(response).to have_http_status(:not_found)
      end

      it "redirects to checks/index" do
        target = create(:target, value: 5, delta: 5)
        login_as(target.user)

        post(target_refreshes_path(target_id: target.id))

        expect(response).to redirect_to(checks_path)
      end
    end
  end
end
