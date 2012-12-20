# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'app/helpers/wl_launcher'
require 'app/helpers/wl_database'
require 'active_record'

def argsetup(args)
  begin
    user_opt_index = args.index('-u')
    port_opt_index = args.index('-p')
    reset_opt_index = args.index('reset')
    dbid_opt_index = args.index('-db')
    ENV['RESET'] = args[reset_opt_index] if (reset_opt_index)
    ENV['USERNAME'] = args[user_opt_index+1].upcase if (user_opt_index)
    ENV['PORT'] = args[port_opt_index+1] if (port_opt_index)
    ENV['DBID'] = args[dbid_opt_index+1] if (dbid_opt_index)
    2.times { args.delete_at(user_opt_index)} if user_opt_index
    args.delete_at(reset_opt_index) if reset_opt_index
    2.times { args.delete_at(dbid_opt_index)} if db_opt_index
    ENV['USERNAME'] = 'MANAGER' if ENV['USERNAME'].nil?
    ENV['PORT'] = '3000' if ENV['PORT'].nil?
    ENV['DBID'] = ENV['USERNAME'] if ENV['DBID'].nil?
    if  ENV['USERNAME']=='MANAGER'
      if ENV['RESET']
        include Database
        #XXX This does not remove customly created databases 
        destroy_all
      end
      puts "Server is a WLInstance Manager."
    else
      puts "Server is a WLInstance."  
    end    
  rescue
    display_help
    exit
  end
  Rails.logger.info "#{ENV['USERNAME']} is running Wepic on port #{ENV['PORT']}"
end

def database_environment_setup
  include Database
  # Override the connection created from database.yml
  configuration = YAML::load(File.open(File.join(ENV['RAILS_ROOT'],'config/database.yml')))[ENV['RAILS_ENV']]
  db_name = "#{ENV['RAILS_ENV']}_#{ENV['USERNAME']}"
  configuration['database'] = db_name
  create_or_connect_db(configuration)
  Rails.logger.info "Overriding rails default database configuration..."
end

def display_help
  Rails.logger.info "---------WEPIC HELP------------"
  s = "Usage is the same as for regular rails apps, with extra options :\n"
  s += "\t-u specifies a user. Default user is called manager. A wepic manager supervises several wepic peers. Other users become wepic peers, with their own webdamlog instance and rails server.\n"
  s += "\t -p specifies a port. This option is similar to that of rails.\n"
  s += "\t -db specifies a database id. By default, the database id will be the same as the username. This ensures that a user may have several databases, although it will have one instance per database.\n"
  s += "\t reset (only for manager) means that upon start the manager will clean all pre-existing wepic peers and their
  databases. An option to kill the wepic peer instances but keep the database contents is available with the \"Kill all peers\" button
  in the admin section.\n"
  Rails.logger.info s
end