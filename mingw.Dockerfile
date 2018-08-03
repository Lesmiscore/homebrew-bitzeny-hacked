FROM ubuntu AS build

ENV DEBIAN_FRONTEND=noninteractive
ARG REF=z2.0.0a
ARG REPO=bitzenyPlus/BitZenyPlus

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y build-essential \
    libtool autotools-dev autoconf \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    pkg-config \
    software-properties-common \
    git wget curl \
    g++-mingw-w64-x86-64 \
    bsdmainutils \
    qtbase5-dev-tools qtbase5-dev && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update && \
  apt-get install -y libdb4.8-dev libdb4.8++-dev && \
  git clone https://github.com/${REPO}.git /bitzeny && \
  cd /bitzeny && \
  git checkout "$REF" && \
  cd depends && \
  make HOST=x86_64-w64-mingw32 -j2 && \
  cd .. && \
  ./autogen.sh && \
  CONFIG_SITE=depends/x86_64-w64-mingw32/share/config.site ./configure --host=x86_64-w64-mingw32 --without-miniupnpc --disable-tests --with-boost=depends/x86_64-w64-mingw32/include/boost/ --with-qt-bindir=depends/x86_64-w64-mingw32/bin/ && \
  make -j8
