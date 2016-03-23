#!/bin/bash

die () { echo -e "$@" >&2; exit 1; }

[ "$1" ] || die "Usage: $0 <server_fqdn>"


HOSTS_PATH='/etc/hosts'
NETWORK_PATH="/etc/sysconfig/network"
system_fqdn="$1"
host_name=$(echo $system_fqdn |cut -d"." -f1)

echo " setting hostname for machine"
hostname "${host_name}"

while [[ -z $ipaddress ]]
do
  ipaddress=$(/opt/puppetlabs/bin/facter ipaddress)
done

if grep "${system_fqdn}" "${HOSTS_PATH}" -q; then
  echo " DNS name already exists in ${HOSTS_PATH} "
else
  echo " adding hosts entry. "
  echo -e "${ipaddress}\t${system_fqdn} ${host_name}" >> ${HOSTS_PATH}
fi


if grep "${system_fqdn}" ${NETWORK_PATH} -q; then
  echo " Hostname already set in ${NETWORK_PATH} "
else
  echo " adding hostname to ${NETWORK_PATH}"
  echo "HOSTNAME=${system_fqdn} " >> ${NETWORK_PATH}
fi

