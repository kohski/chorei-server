# frozen_string_literal: true

class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.integer :job_id, null: false
      t.integer :frequency, null: false, default: 0
      t.integer :repeat_time, null: false, default: 0
      t.datetime :start_at, null: false
      t.datetime :end_at
      t.boolean :is_done, null: false, defaul: false

      t.timestamps
    end
  end
end
