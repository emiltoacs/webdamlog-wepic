class CreateImageLocations < ActiveRecord::Migration
  def change
    create_table :image_locations do |t|
      t.string :title
      t.string :owner
      t.string :location

      t.timestamps
    end
  end
end
