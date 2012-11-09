# ####License####
#  File name loadprogram.rb
#  Copyright © by INRIA
#
#  Contributors : Webdam Team <webdam.inria.fr>
#       Jules Testard <jules[dot]testard[@]mail[dot]mcgill[dot]ca>
#
#   WebdamLog - 30 juin 2011
#
#   Encoding - UTF-8
# ####License####
require '/home/jtesta/projects/svn/WLBud/trunk/src/fr/inria/webdam/webdamlog/wlbud/wlbud'

#these are the main running classes to test our program
class Load_program < WLBud::WL
end

module ApplicationHelper
  def init_session
    str1 = "#{File.expand_path(File.dirname(__FILE__))}/wlprogram/prog1.wl"
    ip1 = '127.0.0.1' ; port1 = '12345'
    @prog = Load_program.new('emilien', str1,
      :ip=>ip1,:port=>port1,
      :debug=>true,:debug2 =>true,
      :dump_rewrite=>false,:dump_ast=>false,:print_wiring=>false,
      :tag => 'prog_a', :trace => false,
      :metrics => true, :mesure => true)
    #As long as the bud database is not setup, we do not use bud
    if false
      @prog.tick
    end    
  end
  
  def close_session
    @prog.stop if !@prog.nil?
    puts "program was stopped..."
  end
end
