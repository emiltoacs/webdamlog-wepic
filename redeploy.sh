#!/bin/bash
pkill -KILL -f ruby
rails -r
rake admin:create
