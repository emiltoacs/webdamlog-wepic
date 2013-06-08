class CreateAdminSessions < ActiveRecord::Migration
  def change
    create_table :admin_sessions do |t|

      t.timestamps
    end
  end
end
