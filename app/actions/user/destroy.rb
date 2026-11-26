# frozen_string_literal: true

# Deletes a user and everything they own, children before parents so the
# foreign keys are never violated.
class User::Destroy
  include JunkDrawer::Callable

  def call(user)
    ActiveRecord::Base.transaction do
      Check.where(user:).find_each { Check::Destroy.call(it) }
      Group.where(user:).delete_all
      Integration.where(user:).delete_all
      ApiKey.where(user:).delete_all
      user.destroy!
    end
  end
end
