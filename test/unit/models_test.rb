# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test_helper'

class ModelsTest < Test::Unit::TestCase
  
  def setup
    @dbid = (0...8).map{('a'..'z').to_a[rand(26)]}.join
    ENV['USERNAME'] = @dbid

    # reload the models to allow builtins tables to be created
    @id = @dbid
    @db_name = 'wp_test'
    @configuration = {:adapter => 'postgresql', :database => @db_name}
    puts "Configuration : id=#{@id.inspect}, db_name=#{@db_name.inspect}, configuration=#{@configuration.inspect}"
    #PostgresHelper::create_user_db #@configuration
    #@database = WLDatabase.establish_orm_db_connection(@id,@db_name,@configuration)
  end
  
  def teardown
    #@database.destroy
  end
  
  def test_simple
    #Test environment
  end
  
  def test_new_picture_remote
    #TODO: Write test
    # picture = Picture.new(:image_url=>"http://1.bp.blogspot.com/-Gv648iUY5p0/UD8rqW3deSI/AAAAAAAAACA/MrG4KxFyM5A/s400/Fish.jpeg",:owner=>"Emilien",:title=>"nemo")
    # picture.save
    # assert_equal(picture.image_file_name,"Fish.jpeg")
    # assert_equal(picture.image_file_size,32824)
    # assert_equal(picture.image_content_type,"image/jpeg")
    # assert_equal(picture.owner,"Emilien")
    # assert_equal(picture.title,"nemo")
    # picture.destroy
  end
#   
  # def test_new_picture_local
    #TODO: Write test
    # picture = Picture.new(:image_url=>"app/assets/images/tiger.jpg",:owner=>"Jules",:title=>"tiger")
    # picture.save
    # assert_equal(picture.image_file_name,"tiger.jpg")
    # assert_equal(picture.image_content_type,"image/jpeg")
    # assert_equal(picture.owner,"Jules")
    # assert_equal(picture.title,"tiger")
    # picture.destroy
  # end  
end
