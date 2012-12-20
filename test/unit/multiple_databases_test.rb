# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'test/unit'
require 'active_record'
require 'app/helpers/wl_database'

class MultipleDatabasesTest < Test::Unit::TestCase
  include Database
  
  #FIXME: this test only works with a db count of 1. The problem is that
  #currenlty the since each instance should only care about a database, each call
  #to create_or_connect db in the setup method will change the ActiveRecord::Base database connection.
  #Since classes from created using the create_relation method use ActiveRecord::Base
  #connection, all classes will attempt to connect to the same db.
  #
  def setup
    @dbcount = 1
    @dbids = Array.new
    (0..@dbcount).each do |i|
      @dbids[i] =  (0...8).map{('a'..'z').to_a[rand(26)]}.join
      create_or_connect_db(@dbids[i])
    end
  end
  
  def teardown
    (0..@dbcount).each do |i|
      database(@dbids[i]).destroy
    end
  end
  
  #This test checks how fast it is to insert a thousand fact into a single database.
  def test_manipulate_databases
    number=1000
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    @dbids.each do |id|
      database(id).create_relation(relation_name,relation_schema)
      assert_equal("Dog",database(id).relation_classes["Dog"].table_name)
    end
       
    @dbids.each do |id|
      puts "insert into db : #{id}"

      (0..number).each do |i|
        count_values = {"name" => "Bobby#{i}", "age" => i, "race"=> "labrador"}
        database(id).relation_classes["Dog"].insert(count_values)
      end
      assert_equal(number+1,database(id).relation_classes["Dog"].all.size)

    end
    
    @dbids.each do |id|
      number_of_tuples_to_delete = rand(number)
      (1..number_of_tuples_to_delete).each do |i|
        database(id).relation_classes["Dog"].delete(i)
      end
      assert_equal(number+1-number_of_tuples_to_delete,database(id).relation_classes["Dog"].all.size)
    end
    
  end
  
  def test_images_upload
    
  end
  
end
