FROM ubuntu AS build

ENV DEBIAN_FRONTEND=noninteractive
ARG REF=z2.0.0a

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y build-essential \
    libtool autotools-dev autoconf \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    pkg-config \
    software-properties-common \
    git wget && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update && \
  apt-get install -y libdb4.8-dev libdb4.8++-dev && \
  git clone https://github.com/BitzenyCoreDevelopers/bitzeny.git /bitzeny && \
  cd /bitzeny && \
  git checkout "$REF" && \
  wget -qO- https://gist.github.com/nao20010128nao/84543385ae23e956c38e5d8f1963906e/raw/17e8c74d4e826ad4ffd6276c1ce07791e35a11cb/patchme.diff | patch -p1 && \
  ./autogen.sh && \
  ./configure --prefix=/usr --without-miniupnpc --without-gui --disable-tests && \
  make

FROM ubuntu

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    software-properties-common && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update && \
  apt-get install -y libdb4.8-dev libdb4.8++-dev && \
  apt-get autoremove -y software-properties-common && \
  apt-get clean

COPY --from=build /bitzeny/src/bitzenyd /usr/bin/bitzenyd

VOLUME /root/.bitzeny
EXPOSE 9252 9253

ENTRYPOINT [ "/usr/bin/bitzenyd" ]
