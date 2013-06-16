# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "databasemodeltest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_databasemodeltest"
require 'test/unit'
require './lib/wl_setup'

class WLDatabaseInsertViaActiveRecord < Test::Unit::TestCase
  include WLDatabase

  # test creation of new tuple in ActiveRecord and propagation in wdl relations
  def test_10_add_model
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run_engine
    engine = EngineHelper::WLENGINE
    engine.load_bootstrap_fact
    db.save_facts_for_meta_data

    db.relation_classes['Contact'].new(:username=>'name',:peerlocation=>'peerlocation',:online=>false,:email=>'email',:facebook=>'facebook').save

    assert_equal 3, engine.tables[:contact_at_databasemodeltest].to_a.size
    array = engine.tables[:contact_at_databasemodeltest].to_a.sort.map{ |item| item.values }
    assert_equal [["Jules","localhost:4100","false","jules.testard@mail.mcgill.ca","Jules Testard"],
      ["Julia", "localhost:4100", "false", "stoyanovich@drexel.edu", "jstoy"],
      ["name", "peerlocation", false, "email", "facebook"]], array
  end
  
end