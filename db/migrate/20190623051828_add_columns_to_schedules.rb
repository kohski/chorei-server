# frozen_string_literal: true

class AddColumnsToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :start_at, :datetime, null: false
    add_column :schedules, :end_at, :datetime, null: false
  end
end
