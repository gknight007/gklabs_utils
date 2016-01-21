#!/bin/bash


die () { echo -e "$*" >&2 ; exit 1; }

url="https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz"
tgzName=$(basename $url)
pyName=${tgzName/.tgz/}
startPwd=$PWD
md5='e80a0c1c71763ff6b5a81f8cc9bb3d50'

sudo yum -y groupinstall 'Development Tools' || die

sudo yum install -y sqlite-devel || die

mkdir python-build python-prefix

cd python-build || die

[ -e "$tgzName" ] || ( wget $url || die )
#FIXME: add check for MD5

tar -zxf $(basename $url) || die

cd $pyName || die

export CFLAGS='-fPIC'
./configure --prefix=${startPwd}/python-prefix || die 

make || die

make install 

