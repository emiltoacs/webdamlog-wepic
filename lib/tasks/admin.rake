require 'yaml'

namespace :admin do
  desc "Create administrator profiles according to config/admin.yml"
  task :create => :environment do
    sample_content_file_name = "config/admin.yml"
    begin content = YAML.load(File.open(sample_content_file_name))
      content.each do |admin|
        
      end
    rescue => error
      puts error.backtrace
    end
    Admin.new(:login => 'jules', :password => '1234', :password_confirmation => '1234').save
  end
end