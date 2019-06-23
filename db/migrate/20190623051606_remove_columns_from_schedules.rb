# frozen_string_literal: true

class RemoveColumnsFromSchedules < ActiveRecord::Migration[5.2]
  def change
    remove_column :schedules, :frequency, :integer
    remove_column :schedules, :repeat_time, :integer
    remove_column :schedules, :start_at, :datetime
    remove_column :schedules, :end_at, :datetime
  end
end
