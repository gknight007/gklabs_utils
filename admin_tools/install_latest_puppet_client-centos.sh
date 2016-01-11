#!/bin/bash

die () { echo -e "$*" >&2; exit 1; }
warn () { echo -e "$*" >&2; }

yoYum () { echo yum -y $*; return $?; }

pkgInstalled () {
  [ -z "$1" ] && return 1
  yum list installed "$1" &> /dev/null;
  return $?
}


unameArch=$(uname -m)
centosMajorVer=$(cat /etc/centos-release | awk '{print $3}' | cut -d. -f1)

if  [ "$unameArch" == "x86_64" ]; then
  arch="$unameArch"
else
  arch="i386"
fi


epelRpm="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${centosMajorVer}.noarch.rpm"
relRpm="http://yum.puppetlabs.com/el/${centosMajorVer}/products/${arch}/puppetlabs-release-6-11.noarch.rpm"

if ! pkgInstalled 'epel-release'; then
  yoYum install "$epelRpm" || die "ERROR: Unabe to install EPEL release RPM"
fi

if ! pkgInstalled 'puppetlabs-release'; then
  yoYum install "$relRpm" || die "ERROR: Unable to install Puppet release RPM"
fi


if ! pkgInstalled 'puppet'; then
  yoYum install puppet || die "ERROR: Unable to install Puppet"
fi

