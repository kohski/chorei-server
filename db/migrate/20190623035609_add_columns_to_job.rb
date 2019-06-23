# frozen_string_literal: true

class AddColumnsToJob < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :frequency, :integer, default: 0
    add_column :jobs, :repeat_times, :integer, default: 0
    add_column :jobs, :base_start_at, :datetime
    add_column :jobs, :base_end_at, :datetime
  end
end
