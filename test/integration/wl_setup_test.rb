ENV['USERNAME'] = 'manager'
ENV['PORT'] = '4000'
require 'test_helper'
require 'wl_setup'

class WLSetupTest < ActionController::IntegrationTest

  # Test with sqlite3
  def test_sqlite3_clean_orphaned_peer    
    Conf.db['adapter'] = 'sqlite3'
    Conf.db['database'] = 'db/database_manager.db'
    assert File.exists?("db")
    assert_equal Rails.root, Pathname.getwd
    File.delete('db/database_manager.db') if File.exists?('db/database_manager.db')
    WLSetup.clean_orphaned_peer
    assert_equal 0, Dir.glob('db/database_*.db').length, "there should be zero databases"
    File.new('db/database_manager.db', 'w')
    File.new('db/database_other_peer.db', 'w')
    # See the two notation for glob Dir[] or Dir.glob()
    assert_equal 2, Dir['db/database_*.db'].length, "there should be two databases"
    WLSetup.clean_orphaned_peer
    assert_equal 2, Dir['db/database_*.db'].length, "there should be two databases"
    File.delete('db/database_other_peer.db') if File.exists?('db/database_other_peer.db')
    WLSetup.clean_orphaned_peer    
    assert_equal 1, Dir.glob('db/database_*.db').length, "there should be one databases"
    system 'rm db/database_*.db'
    assert_equal 0, Dir.glob('db/database_*.db').length, "there should be zero databases"
  end

  # Test with postgres
  def test_postgres_clean_orphaened_peer
    
  end
end
