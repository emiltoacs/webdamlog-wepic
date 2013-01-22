# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'lib/wl_launcher'
require 'yaml'

module WLSetup
  
  #The dbsetup method is used for clean up the database environment in case, for
  #instance, of a database reset, or if the manager database is missing.
  #TODO : dbsetup should also check the consistency between the databases present
  #and those that are cited in the account table for the manager database.
  #
  def self.dbsetup(db_type)
    case db_type
    when :sqlite3
      admin_present = false
      `ls -la db/*.db`.split("\n").each do |line|
        if line.split(" ").last.include?("database_MANAGER.db")
          #Do nothing, admin db is already present.
          admin_present=true;
        end
      end
      if !admin_present
        #Remove all .db files
        system 'rm db/*.db'
        puts "database_MANAGER.db file absent. Recreating database..."
        #Migrate the db appropriately
        system 'bundle exec rake db:migrate'
        puts "Database migrated."
      end
    end
  end
  
  #The argsetup method is used for preliminary setup (before conventional rails
  #setup is done) to take care of wepic-specific options given to the rails commandline
  #command.
  #
  def self.argsetup(args)
    properties = YAML.load_file('config/properties.yml')
    user_opt_index = args.index('-u')
    port_opt_index = args.index('-p')
    ENV['USERNAME'] = args[user_opt_index+1].upcase if (user_opt_index)
    ENV['PORT'] = args[port_opt_index+1] if (port_opt_index)
    2.times { args.delete_at(user_opt_index)} if user_opt_index
    ENV['USERNAME'] = 'MANAGER' if ENV['USERNAME'].nil?
    ENV['PORT'] = properties['communication']['manager_port'].to_s if ENV['PORT'].nil?
    if  ENV['USERNAME']=='MANAGER'
      puts "Server is a WLInstance Manager."
      dbsetup(:sqlite3)
    else
      puts "Server is a WLInstance."  
    end
    puts "#{ENV['USERNAME']} is running Wepic on port #{ENV['PORT']}"
  end
  
end
