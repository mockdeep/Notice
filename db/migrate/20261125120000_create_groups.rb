# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_groups

    safety_assured do
      add_reference :checks, :group, foreign_key: true, index: false
      up_only { backfill_general_groups }
      change_column_null :checks, :group_id, false
      remove_index :checks, [:user_id, :name], unique: true
      add_index :checks, [:group_id, :name], unique: true
    end
  end

  private

  def create_groups
    create_table :groups do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :name, null: false
      t.timestamps

      t.index [:user_id, :name], unique: true
    end
  end

  def backfill_general_groups
    execute(<<~SQL.squish)
      INSERT INTO groups (user_id, name, created_at, updated_at)
      SELECT id, 'General', NOW(), NOW() FROM users
    SQL

    execute(<<~SQL.squish)
      UPDATE checks SET group_id = groups.id
      FROM groups
      WHERE groups.user_id = checks.user_id
    SQL
  end
end
