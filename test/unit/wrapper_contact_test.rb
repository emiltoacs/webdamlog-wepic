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

  def test_contact_wrapper
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

    # test propagation of ip port in wdl and peer declaration
    assert Contact.new( username: "testusername", ip: "127.0.0.1", port: "5040" ).save
    
    assert_equal [["Jules", "127.0.0.1", 4100, false, "jules.testard@mail.mcgill.ca"],
      ["Julia", "127.0.0.1", 4150, false, "stoyanovich@drexel.edu"],
      ["wrapperruletest", "127.0.0.1", 54867, true, "none"],
      ["testusername", "127.0.0.1", 5040, nil, nil]],
      Contact.all.map { |tup| [tup[:username], tup[:ip], tup[:port], tup[:online], tup[:email]] }
  end
  
end
