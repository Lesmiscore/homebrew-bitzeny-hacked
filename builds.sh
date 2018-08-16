#!/bin/bash
# depends-aware build script
# uses depends if required
set -e


_mustfile() {
  [ -e $1 ] && [ -f $1 ]
}

_configure() {
  if _mustfile configure ; then
    ./configure --prefix=/usr --without-miniupnpc --without-gui --disable-tests --disable-bench
  fi
}

_makefile() {
  if _mustfile autogen.sh ; then
    ./autogen.sh
  elif _mustfile CMakeLists.txt ; then
    cmake .
  fi
}

if [ $USE_DEPENDS != "no" ]; then
  if [ $USE_DEPENDS != "yes" ]; then
    # use specified file for depends
    rm -rf depends/
    wget -q -O /tmp/file.zip "$USE_DEPENDS"
    mkdir /tmp/work
    unzip /tmp/file.zip -d /tmp/work
    mv /tmp/work/*/depends .
  fi
  # compile w/ depends, used for insane coin
  cd depends/
  # no HOST, because we compile it for ourselves
  make -j${JOBS} NO_QT=yes
  cd ..
  _makefile
  CONFIG_SITE="$PWD/$(tree -fai | grep config.site | grep -vE 'in$')" _configure
  make -j${JOBS}
else
  # compiles normally
  _makefile
  _configure
  make -j${JOBS}
fi


strip src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx
file  src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx
ldd   src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx
