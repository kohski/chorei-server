class AddGroupIdToTag < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :group_id, :integer, null: false
  end
end
