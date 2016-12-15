class CreateVenues < ActiveRecord::Migration[5.0]
  def change
    create_table :venues do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :address
      t.string :city
      t.integer :eb_id

      t.timestamps
    end
  end
end
