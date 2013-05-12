#!/bin/bash

#Add these lines in your pg_hba.conf
#Database administrative login by Unix domain socket
#local   all             postgres                                trust
# "local" is for Unix domain socket connections only
#local   all             all                                     trust
#and reset the postgresql server :
#sudo service postgresql stop && sudo service postgresql start
#
#make sure your main unix user can create databases.


# Create the postgres user wepic with right to create new databases along with the wepic database that may be useless if another is specified in database.yml
sudo -u postgres createuser -d -R -S wepic
sudo -u postgres createdb -O wepic wp_manager
