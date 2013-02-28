require 'test_helper'
require 'user'

class UserTest < ActiveSupport::TestCase

  # Doc about validation found on
  # http://guides.rubyonrails.org/active_record_validations_callbacks.html
  test "test invalid tuple insertion" do
    user = User.new
    assert user.new_record?, "this new tuple has not been stored in the database yet"
    assert !user.valid?, "no fields should be nil, validation must fail"
    assert !user.save, "no fields should be nil, save record must fail"
  end

end
