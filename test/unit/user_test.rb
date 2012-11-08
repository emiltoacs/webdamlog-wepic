require 'test_helper'

class UserTest < ActiveSupport::TestCase
  #Test if it is possible to dynamically add a table to the db 
  #that corresponds to a WL Collection
  test "dbLoad" do
    assert true
  end  
  
  #Test if it is possible to add and load dynamically a rails model
  #corresponding to the WLCollections
  test "classLoad" do
    assert true
  end
  
  #Test if it is possible to insert in the newly created model
  test "insert" do
    assert true
  end
  
  #Test if it is possible to retrieve information from the database
  test "retrieve" do
    assert true
  end
end
