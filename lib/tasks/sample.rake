require 'yaml'
require 'wl_tool'

namespace :sample do
  desc "Create sample data for peer according to config/scenario/samples/username_sample.yml. For internal use only."
  task :create => [:environment, :clear] do
    begin
      SampleHelper::create
      # if defined?(Conf) #and Conf.env['USERNAME']!='manager'
        # WLLogger.logger.debug "Samples added for user #{Conf.env['USERNAME']} : #{Conf.db['sample_content']}"
        # sample_content_file_name = "#{Rails.root}/config/scenario/samples/#{Conf.env['USERNAME']}_sample.yml"
        # if (File.exists?(sample_content_file_name))
          # content = YAML.load(File.open(sample_content_file_name))
          # WLLogger.logger.info "Load sample specification from yaml file"
          # content['contacts'].values.each do |contact|
            # #We should check if users are online using Webdamlog rules.
            # Contact.new(:username=>contact['name'],:peerlocation=>contact['peerlocation'],:online=>false,:email=>contact['email'],:facebook=>contact['facebook']).save
          # end unless content['contacts'].values.nil?
          # content['pictures'].values.each do |picture|
            # owner = if picture['owner'] then picture['owner'] else Conf.env['USERNAME'] end
            # Picture.new(:image_url=>picture['url'],:owner=>owner,:title=>picture['title']).save
          # end unless content['pictures'].values.nil?
          # content['locations'].values.each do |imagelocation|
            # owner = if imagelocation['owner'] then imagelocation['owner'] else Conf.env['USERNAME'] end
            # Picture.where(:title=>imagelocation['title'],:owner=>owner).first.located = imagelocation['location']
          # end unless content['locations'].values.nil?
          # content['ratings'].values.each do |rating|
            # owner = if rating['owner'] then rating['owner'] else Conf.env['USERNAME'] end
            # Picture.where(:title=>rating['title'],:owner=>owner).first.rated = rating['rating']
          # end unless content['ratings'].values.nil?
          # content['comments'].values.each do |comment|
            # owner = if comment['owner'] then comment['owner'] else Conf.env['USERNAME'] end
            # picture = Picture.where(:title=>comment['title'],:owner=>owner).first
            # Comment.insert(:_id=>picture._id,:text=>comment['text'],:author=>comment['author']) if picture
          # end
        # else
          # raise "file #{sample_content_file_name} does not exist!"
        # end
      # else
      # raise "The Conf object has not been setup!"
      # end
    rescue Exception
      puts $!, $@
    end
  end
  
  desc "Clears the common data of a wepic peer."
  task :clear => :environment do
    begin
      puts "clear task empy."
      puts "Contacts relation cleared..." if Contact.delete_all
      puts "Pictures relation cleared..." if Picture.delete_all
      puts "Comments relation cleared..." if Comment.delete_all
      puts "Ratings relation cleared..." if Rating.delete_all
      puts "Picture_Location relation cleared..." if PictureLocation.delete_all   
    rescue Exception
      puts $!, $@      
    end
  end
  
  desc "Show the contents of the database"
  task :show => :environment do
    begin
      classes = ['Contact','Picture','Comment','Rating','PictureLocation']
      classes.each do |_class|
        _class.constantize.all.each_with_index do |element,i|
          puts "#{_class.inspect}[#{i}]:#{element.inspect}"
        end
      end
    rescue Exception
      puts $!, $@
    end
  end
end