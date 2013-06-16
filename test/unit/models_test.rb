# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "modelstesttest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_modelstesttest"
require 'test/unit'
require './lib/wl_setup'

class ModelsTest < Test::Unit::TestCase
  
  def test_rating
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run_engine
    engine = EngineHelper::WLENGINE
    engine.load_bootstrap_fact
    db.save_facts_for_meta_data
    
    rating = Rating.new(:rating => 3, :owner=>'jules', :_id => 12345)
    rating.save
    assert_equal(3,rating.rating)
  end
  
  def test_new_picture_remote
    #TODO: Write test #:date => DateTime.now,
    
    picture = Picture.new(:owner=>"Emilien",:title=>"nemo") #:remote_image_url=>"http://1.bp.blogspot.com/-Gv648iUY5p0/UD8rqW3deSI/AAAAAAAAACA/MrG4KxFyM5A/s400/Fish.jpeg"
    picture.save
    assert_equal(picture.image_file_name,"Fish.jpeg")
    assert_equal(picture.image_file_size,32824)
    assert_equal(picture.image_content_type,"image/jpeg")
    assert_equal(picture.owner,"Emilien")
    assert_equal(picture.title,"nemo")
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
