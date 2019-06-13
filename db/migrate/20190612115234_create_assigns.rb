# frozen_string_literal: true

class CreateAssigns < ActiveRecord::Migration[5.2]
  def change
    create_table :assigns do |t|
      t.integer :member_id, null: false
      t.integer :job_id, null: false

      t.timestamps
    end
  end
end
