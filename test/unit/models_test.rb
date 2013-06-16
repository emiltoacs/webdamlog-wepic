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
  
  def test_rating
    rating = Rating.new(:rating => 3, :owner=>'jules', :_id => 12345)
    rating.save
    assert_equal(3,rating.rating)
  end
  
  def test_new_picture_remote
    #TODO: Write test #:date => DateTime.now,
    puts "hey"
    picture = begin
      tuple = Picture.new(:owner=>"Emilien",:title=>"nemo", :image_url=>"http://1.bp.blogspot.com/-Gv648iUY5p0/UD8rqW3deSI/AAAAAAAAACA/MrG4KxFyM5A/s400/Fish.jpeg")
      tuple.save
      tuple
    rescue
      puts $!, $@
    end
    assert_equal("Fish.jpeg",picture.image_file_name)
    assert_equal(32824,picture.image_file_size)
    assert_equal("image/jpeg",picture.image_content_type,)
    assert_equal("Emilien",picture.owner)
    assert_equal("nemo",picture.title)
    picture.destroy
  end
#   
  # # def test_new_picture_local
    # #TODO: Write test
    # picture = Picture.new(:image_url=>"app/assets/images/tiger.jpg",:owner=>"Jules",:title=>"tiger")
    # picture.save
    # assert_equal(picture.image_file_name,"tiger.jpg")
    # assert_equal(picture.image_content_type,"image/jpeg")
    # assert_equal(picture.owner,"Jules")
    # assert_equal(picture.title,"tiger")
    # picture.destroy
  # # end  
end
