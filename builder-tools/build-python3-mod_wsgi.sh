#!/bin/bash

[vagrant@localhost mod_wsgi-4.4.21]$ rpm -ql mod_wsgi
/etc/httpd/conf.modules.d/10-wsgi.conf
/usr/lib64/httpd/modules/mod_wsgi.so
/usr/share/doc/mod_wsgi-3.4
/usr/share/doc/mod_wsgi-3.4/LICENCE
/usr/share/doc/mod_wsgi-3.4/README


die () { echo -e "$*" >&2; exit 1; }

url='https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.21.tar.gz'
tgzName=$(basename $url)
ver=${tgzName/.tar.gz/}
startPwd=$PWD
prefixDir=$startPwd/mod_wsgi-prefix
modConfOutDir="$prefixDir/etc/httpd/conf.modules.d"
modOutDir="$prefixDir/usr/lib64/httpd/modules"
shareOutDir="$prefixDir/usr/share/doc/mod_wsgi-$ver"

py3=$(which python3)
[ -z "$py3" ] && die "ERROR: Unable to find python3 in \$PATH"


mkdir -p mod_wsgi-build mod_wsgi-prefix
mkdir -p $modConfOutDir $modOutDir $shareOutDir

cd mod_wsgi-build || die

[ -e "$tgzName" ] || ( wget $url || die )

tar -zxf "$tgzName" || die

cd mod_wsgi-$ver || die

srcBuildDir=$PWD
relLibOutDir='src/server/.libs/'

export CFLAGS="-fPIC"

./configure \
  --prefix ${startPwd}/mod_wsgi-prefix \
  --with-python $py3 || die

make || die

cp 'src/server/.libs/mod_wsgi.so' $modOutDir
echo 'LoadModule wsgi_module modules/mod_wsgi.so' > "$modConfOutDir/10-wsgi.conf"
cp README.rst $shareOutDir
cp LICENSE $shareOutDir

fpm \
  -C $prefixDir \
  -t rpm \
  -s dir \
  -n mod_wsgi3 \
   .
  




