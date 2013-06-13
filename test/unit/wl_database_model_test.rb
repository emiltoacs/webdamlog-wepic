# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "databasemodeltest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_databasemodeltest"
require 'test/unit'
require './lib/wl_setup'

class WLDatabaseModelTest < Test::Unit::TestCase
  include WLDatabase

  # test creation of relation via wdl program and via create_model
  def test_10_add_model
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run
    engine = EngineHelper::WLENGINE
    db.create_model("test_model_created", {"name"=> "string", "other"=>"integer"}, {:wdl=> true})
    assert_not_nil engine.tables[:testmodelcreated_at_databasemodeltest]
    assert_equal 0, engine.tables[:testmodelcreated_at_databasemodeltest].to_a.size
    assert_equal ["name", "other"], engine.tables[:testmodelcreated_at_databasemodeltest].cols
    # TODO test add facts with 3 new facts
    valid, err = engine.update_add_fact({ "testmodelcreated_at_databasemodeltest"=>[["other","1"], ["me","2"], ["guy","3"]] })    
    assert_equal 3, valid.first[1].size
    assert_equal [["other", "1"], ["me", "2"], ["guy", "3"]], valid.first[1]
    assert_equal 0, err.size
    assert_equal({"picture_at_databasemodeltest"=>"Picture",
        "contact_at_databasemodeltest"=>"Contact",
        "picturelocation_at_databasemodeltest"=>"PictureLocation",
        "rating_at_databasemodeltest"=>"Rating",
        "comment_at_databasemodeltest"=>"Comment",
        "describedrule_at_databasemodeltest"=>"DescribedRule",
        "testmodelcreated_at_databasemodeltest"=>"TestModelCreated"},
      helper.wdl_tables_binding)
    assert_equal 3, engine.tables[:testmodelcreated_at_databasemodeltest].to_a.size    
  end

  # TODO test activemodel for intensional

  # TODO test var remo

end