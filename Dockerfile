FROM ubuntu as base

RUN apt-get update -qq -y && \
  apt-get install -y wget aria2 && \
  wget -O /bin/apt-fast https://github.com/ilikenwf/apt-fast/raw/master/apt-fast && \
  chmod +x /bin/apt-fast
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

FROM base AS build

ENV DEBIAN_FRONTEND=noninteractive

ARG REF=z2.0.0a
ARG REPO=bitzenyPlus/BitZenyPlus
ARG BINARY=bitzeny
ARG PATCHES=patches.txt
ARG JOBS=8
# should be NO, because almost coins have sane build program
ARG USE_DEPENDS=no

COPY patch.sh /usr/bin/patch-multi
COPY patches/ /patches/
COPY builds.sh /usr/bin/build-now

RUN apt-fast upgrade -y -qq && \
  apt-fast install -y -qq \
    build-essential \
    libtool autotools-dev autoconf \
    libssl-dev \
    libboost-{system,filesystem,chrono,thread,program-options,test}-dev \
    libevent-dev \
    pkg-config unzip curl \
    software-properties-common \
    git tree cmake \
    clang lld && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-fast update -qq && \
  apt-fast install -y -qq libdb4.8-dev libdb4.8++-dev && \
  rm /usr/bin/ld  && ln -s /usr/bin/ld.lld  /usr/bin/ld && \
  rm /usr/bin/gcc && ln -s /usr/bin/clang   /usr/bin/gcc && \
  rm /usr/bin/g++ && ln -s /usr/bin/clang++ /usr/bin/g++ && \
  git clone https://github.com/${REPO}.git /${BINARY} && \
  cd /${BINARY} && \
  git checkout "$REF" && \
  patch-multi /patches.txt && \
  chmod a+x /usr/bin/build-now && \
  build-now

# wget -qO- https://gist.github.com/nao20010128nao/429b24e3b03e2e12d2a145a728b25aa5/raw/a37ea227a2ba55eaca74e4a0decb4031cb677d68/bitzeny-nohalving.diff | patch -p1 && \
  
FROM base

ARG BINARY=bitzeny

RUN apt-fast update -qq && \
  apt-fast upgrade -y -qq && \
  apt-fast install -y -qq \
    libssl1.1 libevent{,-core,-extra,-pthreads,-openssl}-2.1-6 \
    libboost-{system,filesystem,chrono,thread,program-options,test}1.65.1 \
    software-properties-common && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-fast update -qq && \
  apt-fast install -y -qq libdb4.8-dev libdb4.8++-dev && \
  apt-get autoremove -y -qq software-properties-common && \
  apt-get clean

COPY --from=build /${BINARY}/src/${BINARY}d /usr/bin/${BINARY}d
COPY --from=build /${BINARY}/src/${BINARY}-cli /usr/bin/${BINARY}-cli
COPY --from=build /${BINARY}/src/${BINARY}-tx /usr/bin/${BINARY}-tx

RUN ln -s /usr/bin/${BINARY}d /usr/bin/coind

VOLUME /root/.${BINARY}

ENTRYPOINT [ "/usr/bin/coind" ]
