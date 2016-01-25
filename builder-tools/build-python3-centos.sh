#!/bin/bash


die () { echo -e "$*" >&2 ; exit 1; }

url="https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz"
tgzName=$(basename $url)
pyName=${tgzName/.tgz/}
startPwd=$PWD
md5='e80a0c1c71763ff6b5a81f8cc9bb3d50'
reqPkgList='sqlite-devel openssl-devel rubygems ruby-devel rpm-build'
pyVer=$(basename $(dirname $url))


getPkgs () {
  sudo yum -y groupinstall 'Development Tools' || die
  sudo yum install -y $reqPkgList || die
  sudo gem install fpm || die
}

mkDirs () {  mkdir python-build python-prefix ; }

goToSrcDir () {
  cd python-build || die
  cd $pyName || die
}


buildit () {
  cd python-build || die

  [ -e "$tgzName" ] || ( wget $url || die )
  #FIXME: add check for MD5

  tar -zxf $(basename $url) || die

  cd $pyName || die

  export CFLAGS='-fPIC'
  ./configure --prefix=${startPwd}/python-prefix || die 

  make || die
}


mkRpm () {
  fpm \
    -C $startPwd/python-prefix \
    -t rpm \
    -s dir \
    --prefix /usr \
    --name python3 \
    --version $pyVer \
    --license Python \
    --vendor Python \
    --url 'http://www.python.org' \
    --provides 'python(abi)' \
    --provides 'python' \
    -x '*.pyc' \
} 


case "$1" in 
  rpm)
   ;;
  build)
  ;;
  pkg)
  ;;
  *)
  ;;
esac