FROM debian:buster-slim as build
LABEL maintainer="Joe Block <jpb@unixorn.net>"
LABEL description="miller on debian buster"

RUN apt-get update && \
    apt-get install -y apt-utils ca-certificates --no-install-recommends && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends python3-pip && \
		update-ca-certificates

RUN apt-get install -y autoconf libtool flex automake git build-essential

RUN mkdir /workdir
RUN cd /workdir && \
  git clone https://github.com/johnkerl/miller && \
  cd miller && \
  autoreconf -fiv && \
  ./configure --disable-shared --disable-dependency-tracking && \
  make

FROM debian:buster-slim

RUN apt-get update && \
    apt-get install -y apt-utils ca-certificates --no-install-recommends && \
    apt-get upgrade -y --no-install-recommends && \
		update-ca-certificates && \
		rm -fr /tmp/* /var/lib/apt/lists/*

RUN mkdir -p /usr/local/bin
COPY --from=build /workdir/miller/c/mlr /usr/local/bin

LABEL io.whalebrew.name mlr
LABEL io.whalebrew.config.working_dir '/work'

CMD ["mlr"]