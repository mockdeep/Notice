# frozen_string_literal: true

class GroupsController < ApplicationController
  def index
    groups = current_user.groups.preload(:checks).order(:name)

    render(Views::Groups::Index.new(groups:))
  end

  def new
    render(Views::Groups::New.new(group: Group.new))
  end

  def edit
    render(Views::Groups::Edit.new(group: find_group, last_group: last_group?))
  end

  def create
    group = current_user.groups.new(group_params)
    if group.save
      flash[:success] = t(".success")
      redirect_to(groups_path)
    else
      flash.now[:error] = t(".error")
      render(Views::Groups::New.new(group:), status: :unprocessable_content)
    end
  end

  def update
    group = find_group
    if group.update(group_params)
      flash[:success] = t(".success")
      redirect_to(groups_path)
    else
      flash.now[:error] = t(".error")
      view = Views::Groups::Edit.new(group:, last_group: last_group?)
      render(view, status: :unprocessable_content)
    end
  end

  def remove
    group = find_group
    checks = group.checks.order(:name)

    render(Views::Groups::Remove.new(group:, checks:, last_group: last_group?))
  end

  def destroy
    Group::Destroy.call(find_group)

    flash[:success] = t(".success")
    redirect_to(groups_path)
  rescue Group::Destroy::LastGroupError
    flash[:error] = t(".last_group")
    redirect_to(groups_path)
  end

  private

  def group_params
    params.expect(group: [:name])
  end

  def find_group
    current_user.groups.find(params.expect(:id))
  end

  def last_group?
    current_user.groups.one?
  end
end
