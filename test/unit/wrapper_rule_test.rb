# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "wrapperruletest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_wrapperruletest"
require 'test/unit'
require './lib/wl_setup'

class WrapperRuleTest < Test::Unit::TestCase
  
  def test_describedrule
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    # load the database and base model including describedrule
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run_engine
    engine = EngineHelper::WLENGINE
    db.save_facts_for_meta_data
    engine.load_bootstrap_fact
    
    assert_not_nil db
    klassperson = db.create_model("person", {"id"=> "string", "name"=>"string"}, {wdl: true})
    assert_not_nil klassperson
    assert_equal "person_at_wrapperruletest", klassperson.wdl_tabname
    klassfriend = db.create_model("friend", {"id"=> "string", "name"=>"string"}, {wdl: true})
    assert_not_nil klassfriend
    assert_equal "friend_at_wrapperruletest", klassfriend.wdl_tabname
    DescribedRule.new(
      description: "first rule",
      wdlrule: "rule person@local($id,$name) :- friend@local($id,$name);",
      role: "update" ).save
    
    assert_equal [], DescribedRule.all
  end
  
end
