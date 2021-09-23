ARG bash_version

FROM bash:${bash_version}

RUN apk add --no-cache git curl \
	&& git config --global user.email "user@example.com" \
	&& git config --global user.name "User Name"

COPY . /opt/basalt/source

WORKDIR /opt/basalt/source
ENTRYPOINT ["/opt/basalt/source/.workflow-data/bats-core/bin/bats"]
