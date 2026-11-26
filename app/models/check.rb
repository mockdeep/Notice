# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :integration
  belongs_to :group
  belongs_to :latest_count, class_name: "Count"
  has_one :target, dependent: :delete
  has_many :counts, dependent: :delete_all

  validates :name, presence: true, uniqueness: { scope: :group_id }
  validates :integration_id, :group_id, :user_id, :target, presence: true
  validate :group_belongs_to_user

  accepts_nested_attributes_for :target, update_only: true

  scope(
    :last_counted_before,
    lambda { |timestamp|
      left_joins(:counts)
          .having(
            "MAX(counts.created_at) < ? OR COUNT(counts) = 0",
            timestamp,
          )
          .group("checks.id")
    },
  )

  # Lowest to highest.
  PRIORITIES = [:normal, :high, :urgent].freeze

  delegate :value, to: :target, prefix: true

  def self.top_priority(checks)
    checks.select(&:active?).map(&:priority).max_by { PRIORITIES.index(it) }
  end

  def self.model_name
    ActiveModel::Name.new(base_class)
  end

  def manual?
    false
  end

  def active?
    last_value.present? && last_value > target.value
  end

  # Every check is normal priority until checks get a priority setting.
  def priority
    :normal
  end

  def refresh=(refresh)
    Check::Refresh.call(self) if ["true", true].include?(refresh)
  end

  def next_count
    raise NotImplementedError, "next_count should be implemented on sub-classes"
  end

  def last_value
    latest_count && latest_count.value
  end

  private

  def group_belongs_to_user
    return if group.nil? || group.user_id == user_id

    errors.add(:group, "must be one of your groups")
  end
end
