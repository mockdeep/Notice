# frozen_string_literal: true

# Lowers targets early, so checks that haven't reached their goal target
# show up in "Needs attention" sooner.
class Target::RefreshesController < ApplicationController
  def create
    if params[:checks] == "all"
      Target::RefreshAll.call(current_user)
    else
      target = current_user.targets.find(params.require(:target_id))
      Target::Refresh.call(target, force: true)
    end

    redirect_to(checks_path)
  end
end
