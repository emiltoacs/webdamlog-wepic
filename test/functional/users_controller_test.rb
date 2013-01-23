# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @json_script = {"commit"=>"sign up", "authenticity_token"=>"eFjmh3bR4dsCF+aRWRCldYN2n9gaAaDF8oOFuq8uyXc=",
      "user"=>{"email"=>"jules.testard@gmail.com", "password"=>"[FILTERED]", "password_confirmation"=>"[FILTERED]"}, "utf8"=>"✓"}
  end
  
  def test_validates
    
  end
end
