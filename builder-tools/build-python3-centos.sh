#!/bin/bash


die () { echo -e "$*" >&2 ; exit 1; }

[ -e /etc/centos-release ] || die "ERROR: Is this Centos?  /etc/centos-release is missing!"

url="https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz"
tgzName=$(basename $url)
pyName=${tgzName/.tgz/}
startPwd=$PWD
md5='e80a0c1c71763ff6b5a81f8cc9bb3d50'
reqPkgList='sqlite-devel openssl-devel rubygems ruby-devel rpm-build'
pyVer=$(basename $(dirname $url))
pyShortVer=$(echo -n $pyVer | cut -d. -f1,2)
rpmPrefix='/opt/python3'
centOsMajorVer=$(cat /etc/centos-release | cut -d ' ' -f4 | cut -d\. -f1)
iterationNumber=1

getPkgs () {
  sudo yum -y groupinstall 'Development Tools' || die
  sudo yum install -y $reqPkgList || die
  sudo gem install fpm || die
}

mkDirs () {  mkdir python-build ; }

goToSrcDir () {
  cd python-build || die
  cd $pyName || die
}


buildit () {
  cd python-build || die

  [ -e "$tgzName" ] || ( wget $url || die )
  #FIXME: add check for MD5
  tgzMd5=$(md5sum "$tgzName"  | cut -d' ' -f1)
  [ "$tgzMd5" == "$md5" ] || die "ERROR: MD5 mismatch for $url"

  tar -zxf $(basename $url) || die

  cd $pyName || die

  export CFLAGS='-fPIC'
  ./configure --prefix=${rpmPrefix} || die 

  make || die
  cd $startPwd
}

doInstall () {
  goToSrcDir
  sudo make install || die
  cd $startPwd
}


mkRpm () {
  fpm=$(which fpm)
  if [ -z "$fpm" ]; then
    [ -x "/usr/local/bin/fpm" ] || die "ERROR: Unable to find fpm"
    fpm=/usr/local/bin/fpm
  fi


    #-C $startPwd/python-prefix \
    #--prefix $rpmPrefix \
  $fpm \
    -t rpm \
    -s dir \
    --name python3 \
    --version $pyVer \
    --iteration "${iterationNumber}.el${centOsMajorVer}" \
    --license Python \
    --vendor Python \
    --url 'http://www.python.org' \
    --provides 'python(abi)' \
    --provides 'python' \
    -x '*.pyc' \
    $rpmPrefix
} 

pyBinDir="${rpmPrefix}/bin"
pyManDir="${rpmPrefix}/share/man"

pkgPython () {
  $fpm \
    -t rpm \
    -s dir \
    --name python3 \
    --version $pyVer \
    --iteration "${iterationNumber}.el${centOsMajorVer}" \
    --license Python \
    --vendor Python \
    --url 'http://www.python.org' \
    --provides 'python(abi)' \
    --provides 'python' \
    ${pyBinDir}/pydoc* \
    ${pyBinDir}/python3* \
    ${pyBinDir}/pip3 \
    ${pyBinDir}/pyvenv-$pyShortVer \
    ${pyBinDir}/pyvenv \
    ${pyBinDir}/easy_install-$pyShortVer \
    ${pyManDir}/*/* 
}


pyLibDir="${rpmPrefix}/lib/python${pyShortVer}"
pyDynLoadDir="${pyLibDir}/lib-dynload"

pkgPyLibs () {
  $fpm \
    -t rpm \
    -s dir \
    --name python3-libs \
    --version $pyVer \
    --iteration "${iterationNumber}.el${centOsMajorVer}" \
    --license Python \
    --vendor Python \
    --url 'http://www.python.org' \
    --provides 'python-libs' \
    --provides 'python' \
    ${pyLibDir} \
    ${pyDynLoadDir}/*.so \
    ${pyLibDir}/*.py* \
    ${pyLibDir}/*/*.py* \
    ${pyLibDir}/*/*/*.py* 
}


pkgPyDevel () {
  $fpm \
    -t rpm \
    -s dir \
    --name python3-devel \
    --version $pyVer \
    --iteration "${iterationNumber}.el${centOsMajorVer}" \
    --license Python \
    --vendor Python \
    --url 'http://www.python.org' \
    --provides 'python-libs' \
    --provides 'python' \
    ${rpmPrefix}/include/python3*/* 
}



case "$1" in 
  rpm)
    mkRpm
  ;;
  build)
    buildit
  ;;
  pkg)
    getPkgs
  ;;
  prefix_install)
    doInstall
  ;;
  all)
    getPkgs
    mkDirs
    buildit
    doInstall
    mkRpm
  ;;
  *)
    echo "Usage: $0 <rpm>|<build>|<pkg>|<prefix_install>|<all>"
  ;;
esac
