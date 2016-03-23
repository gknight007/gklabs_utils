#!/bin/bash


cat > $4 <<EOF
[master]
vardir = /opt/puppetlabs/server/data/puppetserver
logdir = /var/log/puppetlabs/puppetserver
rundir = /var/run/puppetlabs/puppetserver
pidfile = /var/run/puppetlabs/puppetserver/puppetserver.pid
codedir = /etc/puppetlabs/code
autosign = True

[agent]
server = $1
ca_server = $2

[main]
dns_alt_names = $3
EOF

