# To change this template, choose Tools | Templates
# and open the template in the editor.

def dbsetup(db_type)
  case db_type
  when :sqlite3
     `ls -la db/*.db`.split("\n").each do |line|
        if line.split(" ").last.include?("admin.db")
          #Do nothing, admin db is already present.
        else
          #Remove all .db files
          system 'rm db/*.db'
          puts "admin.db file absent. Recreating database..."
          #recreate the admin db using rake commands.
          system 'bundle exec rake db:create'
          #Migrate the db appropriately
          system 'bundle exec rake db:migrate'
        end
     end
  end
end