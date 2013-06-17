# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "wrapperruletest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_wrapperruletest"
require 'test/unit'
require './lib/wl_setup'

# load bootstrap_for_test.wl as specified in the conf file peer.yml
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
    engine.load_bootstrap_fact
    db.save_facts_for_meta_data    
    assert_not_nil db
    
    klassperson, relname, sch, instruction = db.create_model("persontest", {"id"=> "string", "name"=>"string"}, {wdl: true})
    assert_not_nil klassperson
    assert_equal "persontest_at_wrapperruletest", klassperson.wdl_tabname
    klassfriend, relname, sch, instruction = db.create_model("familytest", {"id"=> "string", "name"=>"string"}, {wdl: true})
    assert_not_nil klassfriend
    assert_equal "familytest_at_wrapperruletest", klassfriend.wdl_tabname
    db.relation_classes["DescribedRule"].new(
      description: "first rule",
      wdlrule: "rule persontest@local($id,$name) :- familytest@local($id,$name);",
      role: "update" ).save
    
    assert_equal([[1,
          "Get all the titles for my pictures",
          "collection ext per query1@wrapperruletest(title*);",
          "collection"],
        [2,
          "Get all the titles for my pictures",
          "rule query1@wrapperruletest($title) :- picture@wrapperruletest($title, $_, $_, $_);",
          "collection"],
        [3,
          "Get all pictures from all my friends",
          "collection ext per query2@wrapperruletest(title*);",
          "collection"],
        [4,
          "Get all my pictures with rating of 5",
          "collection ext per query3@wrapperruletest(title*);",
          "collection"],
        [5,
          "Get all my pictures with rating of 5",
          "rule deleg_from_wrapperruletest_4_1@sigmod_peer($title, $contact, $id, $image_url) :- picture@wrapperruletest($title, $contact, $id, $image_url);",
          "collection"],
        [6,
          "Create a friends relations and insert all contacts who commented on one of my pictures. Finally include myself.",
          "collection ext per friend@wrapperruletest(name*);",
          "collection"],
        [7,
          "first rule",
          "rule persontest@wrapperruletest($id, $name) :- familytest@wrapperruletest($id, $name);",
          "update"]],
      DescribedRule.all.map { |tup| [tup[:id], tup[:description], tup[:wdlrule], tup[:role] ] })
  end
  
end
