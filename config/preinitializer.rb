# Preliminary setup to take care of wepic-specific options and switches.
# TODO change that for a rake task instead of custom filter
#$:.unshift File.expand_path('../',File.dirname(__FILE__))
require 'lib/wl_setup'

WLSetup.argsetup(ARGV)