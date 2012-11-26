# To change this template, choose Tools | Templates
# and open the template in the editor.

module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end