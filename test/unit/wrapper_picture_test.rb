# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "wrapperruletest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.peer['peer']['program']['file_path'] = 'test/config/bootstap_for test_with_picture.wl'
Conf.db['database']="wp_wrapperruletest"
require 'test/unit'
require './lib/wl_setup'

# test loading picture from files and propagate to AR
class WrapperPictureTest < Test::Unit::TestCase

  def test_describedrule
    # init
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run_engine
    engine = EngineHelper::WLENGINE
    engine.load_bootstrap_fact
    db.save_facts_for_meta_data
    assert_not_nil db

    # test
    picture = Picture.new(:title=>"nemo", :owner=>"Emilien", :image_url=>"http://1.bp.blogspot.com/-Gv648iUY5p0/UD8rqW3deSI/AAAAAAAAACA/MrG4KxFyM5A/s400/Fish.jpeg") #:
    assert_nil picture._id
    assert_not_nil picture.owner
    assert_not_nil picture.title
    assert_not_nil picture.image_url
    picture.valid?
    assert_not_nil picture._id
    require 'debugger' ; debugger 

    picture.save
        
    # check AR values check insertion into db
    assert_equal [["sigmod",
        "Jules",
        "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif",
        "sigmod.gif",
        "image/gif"],
      ["webdam",
        "Julia",
        "http://www.cs.tau.ac.il/workshop/modas/webdam3.png",
        "webdam3.png",
        "image/png"],
      ["me",
        "Jules",
        "http://www.cs.mcgill.ca/~jtesta/images/profile.png",
        "profile.png",
        "image/png"],
      ["nemo",
        "Emilien",
        "http://1.bp.blogspot.com/-Gv648iUY5p0/UD8rqW3deSI/AAAAAAAAACA/MrG4KxFyM5A/s400/Fish.jpeg",
        "Fish.jpeg",
        "image/jpeg"]],
      Picture.all.map { |tup| [tup[:title], tup[:owner], tup[:image_url], tup[:image_file_name], tup[:image_content_type]] }

    Picture.all.map { |tup| assert_not_nil tup[:_id] }

    picture.destroy
  end
  
end

