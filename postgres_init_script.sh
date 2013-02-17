#!/bin/bash

# Database administrative login by Unix domain socket
#local   all             postgres                                trust
# "local" is for Unix domain socket connections only
#local   all             all                                     trust

sudo -u postgres createuser -d -R -S wepic
sudo -u postgres createdb -O wepic wp_manager