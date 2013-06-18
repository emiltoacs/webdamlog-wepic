# Define here all you exceptions
module Exceptions
  # raised by helpers
  class HelperError < StandardError; end
  # raised by wrapper
  class WrappperError < HelperError; end  
  
end
