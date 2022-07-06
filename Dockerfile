FROM debian:buster-slim as builder

WORKDIR /tmp/odyssey/

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    lsb-release \
    ca-certificates \
    libssl-dev \
    libldap-common \
    gnupg \
    openssl \
    ldap-utils \
    libldap-2.4-2 \
    libldap-dev
	
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
	
COPY . /tmp/odyssey/

RUN set -ex \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
                build-essential \
                cmake \
                git \
                libssl-dev \
				postgresql-common \
				postgresql-server-dev-13 \
        && mkdir build \
        && cd build \
        && cmake -DCMAKE_BUILD_TYPE=Release .. \
        && make
		

FROM debian:buster-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    lsb-release \
    ca-certificates \
    libssl-dev \
    libldap-common \
    gnupg \
    openssl \
    ldap-utils \
    libldap-2.4-2 \
    libldap-dev
	
RUN set -ex \
        && apt-get update \
        && apt-get install -y --no-install-recommends libssl-dev \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#COPY ./docker/odyssey.conf /etc/odyssey/configs/

COPY --from=builder /tmp/odyssey/build/sources/odyssey /etc/odyssey/odyssey

EXPOSE 6432
CMD ["/etc/odyssey/odyssey", "/etc/odyssey/configs/odyssey.conf"]