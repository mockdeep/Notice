# frozen_string_literal: true

# Deletes a group along with its checks. Every user keeps at least one
# group, so their last one can't be deleted.
class Group::Destroy
  include JunkDrawer::Callable

  class LastGroupError < StandardError; end

  def call(group)
    ActiveRecord::Base.transaction do
      raise LastGroupError if Group.where(user_id: group.user_id).one?

      Check.where(group:).find_each { Check::Destroy.call(it) }
      group.destroy!
    end
  end
end
