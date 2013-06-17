# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "modelstesttest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_tool'
#Put custom variables (such as db name) here.
Conf.db['database']="wp_modelstesttest"
require 'test/unit'
require './lib/wl_setup'

class ModelsTest < Test::Unit::TestCase
  
  def test_rating
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require './test/test_helper'
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
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require './test/test_helper'
    picture = Picture.new(:owner=>"Emilien",:title=>"nemo") #:remote_image_url=>"http://1.bp.blogspot.com/-Gv648iUY5p0/UD8rqW3deSI/AAAAAAAAACA/MrG4KxFyM5A/s400/Fish.jpeg"
    require 'debugger' ; debugger 
    picture.save
    assert_equal("Fish.jpeg", picture.image_file_name)
    assert_equal(32824, picture.image_file_size)
    assert_equal("image/jpeg", picture.image_content_type)
    assert_equal("Emilien", picture.owner)
    assert_equal("nemo", picture.title)
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
