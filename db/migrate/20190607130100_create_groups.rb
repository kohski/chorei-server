# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.integer :owner_id, null: false
      t.string :name, null: false
      t.string :image

      t.timestamps
    end
  end
end
