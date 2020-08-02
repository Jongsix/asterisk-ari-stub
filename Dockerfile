FROM debian:latest as builder

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install curl build-essential

RUN mkdir -p /usr/src

ENV ASTERISK_VERSION 17.6.0

RUN echo "https://github.com/asterisk/asterisk/archive/$ASTERISK_VERSION.tar.gz"
RUN curl -# -s -L "https://github.com/asterisk/asterisk/archive/$ASTERISK_VERSION.tar.gz" | tar -xzC /usr/src/

RUN apt-get -y install file libedit-dev
RUN apt-get -y install uuid-dev libxml2-dev
RUN apt-get -y install libsqlite3-dev
RUN apt-get -y install libsrtp2-dev
RUN apt-get -y install subversion
RUN apt-get -y install libssl-dev
RUN apt-get -y install libspandsp-dev libopus-dev libspeex-dev


WORKDIR /usr/src/asterisk-$ASTERISK_VERSION 
RUN contrib/scripts/get_mp3_source.s

RUN ./configure \
  --prefix=/usr/local/asterisk \
  --with-jansson-bundled \
  --with-pjproject-bundled 

RUN make menuselect.makeopts
RUN menuselect/menuselect --disable-all menuselect.makeopts
ADD enabled.opts .
RUN for i in $(cat enabled.opts | grep -v '^$' | grep -v '^#') ; do menuselect/menuselect --enable $i menuselect.makeopts ; done
RUN menuselect/menuselect --list-options menuselect.makeopts | grep '^+'
RUN menuselect/menuselect --list-options menuselect.makeopts | grep '^-'

RUN make -j$(nproc) 
RUN make install
RUN make basic-pbx

RUN rm -rf /usr/local/asterisk/etc/asterisk/*

FROM debian:latest AS export

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install libedit2 uuid libxml2 libsqlite3-0 libspandsp2 libopus0 libspeex1 libssl1.1 libsrtp2-1

COPY --from=builder /usr/local/asterisk /usr/local/asterisk

RUN apt-get clean

ADD config/* /usr/local/asterisk/etc/asterisk/
ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
