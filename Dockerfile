ARG bash_version

FROM bash:${bash_version}

RUN apk add --no-cache git \
	&& git config --global user.email "user@example.com" \
	&& git config --global user.name "User Name"

COPY . /opt/bpm/source

WORKDIR /opt/bpm/source
ENTRYPOINT ["/opt/bpm/source/.workflow-data/bats-core/bin/bats"]
