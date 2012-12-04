# To change this template, choose Tools | Templates
# and open the template in the editor.

def dbsetup(db_type)
  case db_type
  when :sqlite3
    admin_present = false
    `ls -la db/*.db`.split("\n").each do |line|
      if line.split(" ").last.include?("admin.db")
        #Do nothing, admin db is already present.
        admin_present=true;
      end
    end
    if !admin_present
      #Remove all .db files
      system 'rm db/*.db'
      puts "admin.db file absent. Recreating database..."
      #Migrate the db appropriately
      system 'bundle exec rake db:migrate'
      puts "Database migrated."
    end
  end
end