require 'yaml'

namespace :admin do
  desc "Create administrator profiles according to config/admin.yml"
  task :create => [:environment, :clear] do
    sample_content_file_name = "config/admin.yml"
    begin
      content = YAML.load(File.open(sample_content_file_name))
      content.values.each do |admin|
        admin.values.each do |val|
          val = val.to_s
        end
        admin = Admin.new(:login => admin['login'], :password => admin['password'], :password_confirmation => admin['password'])
        if admin.save
          puts "#{admin.inspect} was properly saved." 
        else
          raise "Admin was not properly saved! Reason : #{admin.errors.messages}"
        end
      end
    rescue Exception
      puts $!, $@
    end
  end
  task :clear => :environment do
    begin 
      puts "Admin relation cleared..." if Admin.delete_all
    rescue Exception
      puts $!, $@      
    end
  end
end