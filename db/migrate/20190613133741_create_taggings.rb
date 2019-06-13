class CreateTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :taggings do |t|
      t.integer :job_id, null: false
      t.integer :tag_id, null: false

      t.timestamps
    end
  end
end
