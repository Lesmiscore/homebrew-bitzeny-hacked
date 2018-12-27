#!/bin/bash
# depends-aware build script
# uses depends if required
set -e


_mustfile() {
  [ -e $1 ] && [ -f $1 ]
}

_configure() {
  if _mustfile configure ; then
    ./configure C{,XX}FLAGS="-Ofast -g -fPIC" --prefix=/usr --without-miniupnpc --without-gui --disable-tests --disable-bench
  fi
}

_makefile() {
  if _mustfile autogen.sh ; then
    ./autogen.sh
  fi
}

_make() {
  if _mustfile src/makefile.unix ; then
    cd src/
    make -j${JOBS} -f makefile.unix USE_UPNP=-
    cd ..
  elif _mustfile Makefile ; then
    make -j${JOBS}
  fi
}

if [ $USE_DEPENDS != "no" ]; then
  if [ $USE_DEPENDS != "yes" ]; then
    # use specified file for depends
    rm -rf depends/
    wget -q -O /tmp/file.zip "$USE_DEPENDS"
    mkdir /tmp/work
    unzip /tmp/file.zip -d /tmp/work > /dev/null
    mv /tmp/work/*/depends .
  fi
  # compile w/ depends, used for insane coin
  cd depends/
  # guess HOST by using config.guess, with "pc-" removed 
  make -j${JOBS} NO_QT=yes HOST="$(./config.guess | sed 's/pc-//')"
  cd ..
  _makefile
  CONFIG_SITE="$PWD/$(tree -fai | grep config.site | grep -vE 'in$')" _configure
  _make
else
  # compiles normally
  _makefile
  _configure
  _make
fi


strip src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx
file  src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx
ldd   src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx
