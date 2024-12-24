class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :zip_code

      t.timestamps
    end

    add_index :locations, :address
    add_index :locations, :zip_code
  end
end
