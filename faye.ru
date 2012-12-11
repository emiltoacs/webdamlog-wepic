require 'faye'
faye_port = `echo \"$FAYE_PORT\"`
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
bayeux.listen(faye_port)
