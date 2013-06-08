namespace :admin do
  desc "Create administrator profiles according to config/amdin.yml"
  task :create => :environment do
    Admin.new(:login => 'jules', :password => '1234', :password_confirmation => '1234').save
    # Admin.new(:login => 'jules', :password => '1234', :password_confirmation => '1234').save
  end
end