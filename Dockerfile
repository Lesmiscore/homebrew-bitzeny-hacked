FROM ubuntu AS build

ENV DEBIAN_FRONTEND=noninteractive
ARG REF=z2.0.0a
ARG REPO=bitzenyPlus/BitZenyPlus
ARG BINARY=bitzeny
ARG PATCHES=patches.txt

COPY patch.sh /usr/bin/patch-multi
COPY $PATCHES /patches.txt

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
  git clone https://github.com/${REPO}.git /${BINARY} && \
  cd /${BINARY} && \
  git checkout "$REF" && \
  patch-multi /patches.txt && \
  ./autogen.sh && \
  ./configure --prefix=/usr --without-miniupnpc --without-gui --disable-tests --disable-bench && \
  make -j8 && \
  strip src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx && \
  file  src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx && \
  ldd   src/${BINARY}d src/${BINARY}-cli src/${BINARY}-tx

# wget -qO- https://gist.github.com/nao20010128nao/429b24e3b03e2e12d2a145a728b25aa5/raw/a37ea227a2ba55eaca74e4a0decb4031cb677d68/bitzeny-nohalving.diff | patch -p1 && \
  
FROM ubuntu

ARG BINARY=bitzeny

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

COPY --from=build /${BINARY}/src/${BINARY}d /usr/bin/${BINARY}d
COPY --from=build /${BINARY}/src/${BINARY}-cli /usr/bin/${BINARY}-cli
COPY --from=build /${BINARY}/src/${BINARY}-tx /usr/bin/${BINARY}-tx

RUN ln -s /usr/bin/${BINARY}d /usr/bin/coind

VOLUME /root/.${BINARY}
EXPOSE 9252 9253 19252 19253

ENTRYPOINT [ "/usr/bin/coind" ]
