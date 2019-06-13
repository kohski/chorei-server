# frozen_string_literal: true

class CreateSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :steps do |t|
      t.integer :job_id, null: false
      t.text :memo
      t.text :image
      t.integer :order, null: false
      t.boolean :is_done, null: false, default: false

      t.timestamps
    end
  end
end
