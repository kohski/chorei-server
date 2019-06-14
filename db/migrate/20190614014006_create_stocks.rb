# frozen_string_literal: true

class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.integer :user_id, null: false
      t.integer :job_id, null: false

      t.timestamps
    end
  end
end
