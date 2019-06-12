# frozen_string_literal: true

class RemoveOwnerIdColumnFromGroup < ActiveRecord::Migration[5.2]
  def change
    remove_column :groups, :owner_id, :integer
    add_column :members, :is_owner, :boolean, default: false
  end
end
