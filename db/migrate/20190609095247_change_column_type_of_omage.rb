class ChangeColumnTypeOfOmage < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :image, :text
    change_column :groups, :image, :text
  end
end
