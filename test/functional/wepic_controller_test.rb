require 'test_helper'

class WepicControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
