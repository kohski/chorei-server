# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.integer :group_id, null: false
      t.string :title, null: false
      t.text :description
      t.text :image
      t.boolean :is_public, null: false, default: false

      t.timestamps
    end
  end
end
