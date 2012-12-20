# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'active_record'
require 'test/unit'
require 'app/helpers/wl_database'
require 'lib/kernel'


require File.expand_path(File.join(File.dirname(__FILE__),'../../','config/environment'))

#This class is meant to test and explain the database API to be used 
#by the rails controllers and WebdamLog.
#The suppress warning messages are used to avoid constant reassignment warnings.
#Constant reassignment should not be used in practice but is useful for purposes
#of testing.


#TODO : Avoid duplication of information in the Database module by reducing the 
#number of variables.
class DatabaseTest < Test::Unit::TestCase
  include Database
  include Kernel
  
  def setup
    @dbid = (0...8).map{('a'..'z').to_a[rand(26)]}.join
    @database = create_or_connect_db(@dbid)
  end
  
  def teardown
    @database.destroy
  end
  
  def test_setup_and_teardown
    assert(true)
  end
  
  def test_destroy_all  
  end
  
  def test_access_schema_from_class
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    assert_equal(relation_schema,@database.relation_classes[relation_name].schema)
  end
  
  def test_connect_to_db
    #Check if database was created during the setup
    assert_equal(WLInstanceDatabase,@database.class)
    #Check if database contains the WLSchema relation
    assert_equal({"name"=>"string","schema"=>"string"},@database.relation_classes["WLSchema"].schema)
    assert_equal("WLSchema",@database.relation_classes["WLSchema"].table_name)
  end
  
  #TODO enhance test by adding several relations to the testing.
  def test_create_relation
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    #Assert relations has been added to database schemas and relation class attributes.
    assert_equal("Dog",@database.relation_classes["Dog"].table_name)
  end
  
  def test_deconnect
    close_connection(@dbid)
    assert_equal(nil,database(@dbid))
  end
  
  def test_reconnection
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    close_connection(@dbid)    
    @database = create_or_connect_db(@dbid)
    #Schema should contain the Dog table information
    assert_equal(false,@database.relation_classes["WLSchema"].all.empty?)
    assert_equal("Dog",@database.relation_classes["WLSchema"].find(1).name)
  end
  
  def test_insert_and_retrieve
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    bobby = dog_table.find(1)
    assert_equal("Bobby",bobby.name)
    assert_equal(2,bobby.age)
    assert_equal("labrador",bobby.race)
  end
  
  def test_insert_and_retrieve_images
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer", "photo" => "image"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    #TODO change test to select actual picture.
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador", "photo" => nil}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    bobby = dog_table.find(1)
    assert_equal("Bobby",bobby.name)
    assert_equal(2,bobby.age)
    assert_equal("labrador",bobby.race)
  end
  
  def test_delete
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    dog_table.delete(1)
    assert_equal(true,dog_table.all.empty?)
  end
end
