# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WepimApp::Application.initialize!

#Once the application is initialized, if the application is a peer (and not a
#manager), it signals to its manager that it is ready to receive requests).
#
if WepimApp.is_manager?
  require 'lib/wl_launcher'
else
  require 'lib/wl_peer'  
  require 'lib/wl_logger'
  $:.unshift(File.expand_path("lib/webdamlog"))
  require 'lib/webdamlog/wlbud'

  # TODO WLE:START all this messy code for the peer should be moved into an appropriate structure

  #Create a subclass of WL
  klass = Class.new(WLBud::WL)
  # TODO find a good name for the sub class, it should be uniq
  self.class.class_eval "ClassWL#{ENV['USERNAME']}on#{ENV['PORT']} = klass"
  peer_name = "peername_#{ENV['USERNAME']}on#{ENV['PORT']}"
  # TODO find a good place to put the program file
  program_file_dir = File.expand_path('../../tmp/rule_dir', __FILE__)
  unless (File::directory?(program_file_dir))
    Dir.mkdir(program_file_dir)
  end
  program_file = File.join(program_file_dir,"programfile_of_#{ENV['USERNAME']}on#{ENV['PORT']}")
  dir_rule = program_file_dir
  STR0 = <<EOF
peer p0=localhost:11110;
collection ext persistent bootstrap@p0(atom1*);
fact bootstrap@p0(1);
fact bootstrap@p0(2);
fact bootstrap@p0(3);
fact bootstrap@p0(4);
end
EOF
  File.open(program_file, 'w'){ |file| file.write STR0 }
  @webdamlog = nil
  # TODO find a good port for the wlengine
  eval("@webdamlog = ClassWL#{ENV['USERNAME']}on#{ENV['PORT']}.new(peer_name,program_file,{:port => #{ENV['PORT']*2}, :dir_rule => dir_rule})")
  @wlenginelogger = WLLogger::WLEngineLogger.new(STDOUT)
  msg = "peer_name = #{peer_name} program_file = #{program_file} dir_rule = #{dir_rule}"
  if @webdamlog.nil?
    @wlenginelogger.fatal("creation of the webdamlog engine instance has failed:\n#{msg}")
  else
    @wlenginelogger.info("new instance of webdamlog engine created:\n#{msg}")
  end
  #@webdamlog.run_bg

  # XXX add action on shutdown for the wlengine such as erase program file if saved in db and clean rule dir if needed

  # WLE:END

  WLPeer.send_acknowledgment(ENV['USERNAME'],ENV['MANAGER_PORT'],ENV['PORT'])

end