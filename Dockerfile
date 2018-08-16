FROM ubuntu AS build

ENV DEBIAN_FRONTEND=noninteractive
ARG REF=z2.0.0a
ARG REPO=bitzenyPlus/BitZenyPlus
ARG BINARY=bitzeny
ARG PATCHES=patches.txt
ARG JOBS=8
# should be NO, because almost coins have sane build program
ARG USE_DEPENDS=no

COPY patch.sh /usr/bin/patch-multi
COPY $PATCHES /patches.txt
COPY builds.sh /usr/bin/build-now

RUN apt-get update -qq && \
  apt-get upgrade -y -qq && \
  apt-get install -y -qq \
    build-essential \
    libtool autotools-dev autoconf \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    pkg-config unzip curl \
    software-properties-common \
    git wget tree cmake && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update -qq && \
  apt-get install -y -qq libdb4.8-dev libdb4.8++-dev && \
  git clone https://github.com/${REPO}.git /${BINARY} && \
  cd /${BINARY} && \
  git checkout "$REF" && \
  patch-multi /patches.txt && \
  chmod a+x /usr/bin/build-now && \
  build-now

# wget -qO- https://gist.github.com/nao20010128nao/429b24e3b03e2e12d2a145a728b25aa5/raw/a37ea227a2ba55eaca74e4a0decb4031cb677d68/bitzeny-nohalving.diff | patch -p1 && \
  
FROM ubuntu

ARG BINARY=bitzeny

RUN apt-get update -qq && \
  apt-get upgrade -y -qq && \
  apt-get install -y -qq \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    software-properties-common && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update -qq && \
  apt-get install -y -qq libdb4.8-dev libdb4.8++-dev && \
  apt-get autoremove -y -qq software-properties-common && \
  apt-get clean

COPY --from=build /${BINARY}/src/${BINARY}d /usr/bin/${BINARY}d
COPY --from=build /${BINARY}/src/${BINARY}-cli /usr/bin/${BINARY}-cli
COPY --from=build /${BINARY}/src/${BINARY}-tx /usr/bin/${BINARY}-tx

RUN ln -s /usr/bin/${BINARY}d /usr/bin/coind

VOLUME /root/.${BINARY}
EXPOSE 9252 9253 19252 19253

ENTRYPOINT [ "/usr/bin/coind" ]
