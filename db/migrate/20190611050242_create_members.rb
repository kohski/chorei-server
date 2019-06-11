# frozen_string_literal: true

class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.integer :group_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
