class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :username
      t.string :location
      t.boolean :active
      t.integer :pid

      t.timestamps
    end
  end
end
