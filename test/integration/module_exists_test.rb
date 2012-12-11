# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'test/unit'

class ModuleExistsTest < Test::Unit::TestCase
  def test_foo
    require 'pty'
    assert_equal(true,module_exists?('pty'))
  end
  
  def module_exists?(mod)
    begin
      Required::Module::const_get mod
      true
    rescue NameError
      false
    end
  end
end
