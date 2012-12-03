class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :username
      t.string :ip
      t.integer :port

      t.timestamps
    end
  end
end
