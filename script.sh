#!/bin/sh

export FAYE_PORT=3002

exec rackup faye.ru -E production -s thin
