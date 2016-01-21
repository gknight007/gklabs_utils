#!/bin/bash


die () { echo -e "$*" >&2 ; exit 1; }

url="https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz"
tgzName=$(basename $url)
pyName=${tgzName/.tgz/}
startPwd=$PWD
md5='e80a0c1c71763ff6b5a81f8cc9bb3d50'

yum -y groupinstall 'Development Tools'

yum install -y sqlite-devel 

mkdir python-build python-prefix

cd python-build || die

wget $url || die

tar -zxf $(basename $url) || die

cd $pyName || die

export CFLAGS='-fPIC'
./configure --prefix=${startPwd}/python-prefix || die 

make || die

make install 

