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

    db.relation_classes['Contact'].new(:username=>'name',:ip=>'127.0.0.1', :port=>'port', :online=>false,:email=>'email').save

    assert_equal 4, engine.tables[:contact_at_databasemodeltest].to_a.size

    array = engine.tables[:contact_at_databasemodeltest].map { |t| Hash[t.each_pair.to_a] }
    array.each { |h| h.delete :port }
    assert_equal [{:username=>"Jules",
        :ip=>"127.0.0.1",
        :online=>"false",
        :email=>"jules.testard@mail.mcgill.ca"},
      {:username=>"Julia",
        :ip=>"127.0.0.1",
        :online=>"false",
        :email=>"stoyanovich@drexel.edu"},
      {:username=>"databasemodeltest",
        :ip=>"127.0.0.1",
        :online=>"true",
        :email=>"none"},
      {:username=>"name", :ip=>"127.0.0.1", :online=>false, :email=>"email"}], array

    assert_equal [["Jules", "127.0.0.1", false, "jules.testard@mail.mcgill.ca"],
      ["Julia", "127.0.0.1", false, "stoyanovich@drexel.edu"],
      ["databasemodeltest", "127.0.0.1", true, "none"],
      ["name", "127.0.0.1", false, "email"]],
      Contact.all.map { |ar| [ ar[:username], ar[:ip], ar[:online], ar[:email] ] }
  end
  
end