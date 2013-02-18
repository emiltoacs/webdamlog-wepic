# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'test/unit'
require 'active_record'
require 'wl_database'

class MultipleDatabasesTest < Test::Unit::TestCase
  include WLDatabase
  
  def setup
    @dbids = Array.new
    @n = 1
    (0..@n).each do |i|
      @dbids[i] =  (0...8).map{('a'..'z').to_a[rand(26)]}.join
      WLDatabase.create_or_connect_db(@dbids[i])
    end
  end
  
  def teardown
    (0..@n).each do |i|
      database(@dbids[i]).destroy
    end
  end
  
  def test_manipulate_several_databases
  relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    @dbids.each do |id|
      database(id).create_model(relation_name,relation_schema)
      assert_equal("Dog",database(id).relation_classes["Dog"].table_name)
    end
    @dbids.each do |id|
      database(id).relation_classes["Dog"].insert(values)
      bobby = database(id).relation_classes["Dog"].find(1)
      assert_equal("Bobby",bobby.name)
      assert_equal(2,bobby.age)
      assert_equal("labrador",bobby.race)      
    end
    @dbids.each do |id|
      database(id).relation_classes["Dog"].delete(1)
      assert_equal(true,database(id).relation_classes["Dog"].all.empty?)
    end
  end
  
  def test_manipulate_databases
    number=10
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    @dbids.each do |id|
      database(id).create_model(relation_name,relation_schema)
      assert_equal("Dog",database(id).relation_classes["Dog"].table_name)
    end
       
    @dbids.each do |id|
      database(id).relation_classes["Dog"].open_connection
      puts "insert into db : #{id}"

      (0..number).each do |i|
        count_values = {"name" => "Bobby#{i}", "age" => i, "race"=> "labrador"}
        database(id).relation_classes["Dog"].insert(count_values)
      end
      assert_equal(number+1,database(id).relation_classes["Dog"].all.size)

    end
    
    @dbids.each do |id|
      number_of_tuples_to_delete = rand(number)
      database(id).relation_classes["Dog"].open_connection
      (1..number_of_tuples_to_delete).each do |i|
        database(id).relation_classes["Dog"].delete(i)
      end
      assert_equal(number+1-number_of_tuples_to_delete,database(id).relation_classes["Dog"].all.size)
      database(id).relation_classes["Dog"].remove_connection
    end
    
  end  
  
end
