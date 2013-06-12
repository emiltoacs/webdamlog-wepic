# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
#WLSetup.setup_storage(Conf.manager?, Conf.db)
require 'test_helper'

class WLDatabaseModelTest < Test::Unit::TestCase
  include WLDatabase


  def test_10_add_model
    db = WLDatabase.setup_database_server
    assert_not_nil db
    EngineHelper::WLHELPER.run
    db.create_model("test_model_created", {"name"=> "string", "other"=>"integer"}, {:wdl=> true})    
  end

end