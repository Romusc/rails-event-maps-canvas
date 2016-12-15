class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :subcategory
      t.references :venue, foreign_key: true
      t.integer :eb_id, :limit => 8

      t.timestamps
    end
  end
end
