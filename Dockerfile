FROM python:3.9-alpine
LABEL maintainer="pymedusa"

ARG GIT_BRANCH
ARG GIT_COMMIT
ENV MEDUSA_COMMIT_BRANCH $GIT_BRANCH
ENV MEDUSA_COMMIT_HASH $GIT_COMMIT

ARG BUILD_DATE
LABEL build_version="Branch: $GIT_BRANCH | Commit: $GIT_COMMIT | Build-Date: $BUILD_DATE"

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    curl \
    && mkdir /unrar-build

# Download and compile unrar
RUN cd /unrar-build \
    && curl -LO https://www.rarlab.com/rar/unrarsrc-6.2.10.tar.gz \
    && tar -xzf unrarsrc-*.tar.gz \
    && cd unrar \
    && make -f makefile \
    && install -v -m755 unrar /usr/local/bin

# Cleanup build dependencies and temporary files
RUN apk del --no-cache build-base curl \
    && rm -rf /unrar-build

# Verify installation
RUN unrar | head -n 1

# Install packages
RUN \
	# Update
	apk update \
	&& \
	# Runtime packages
	apk add --no-cache \
		mediainfo \
		tzdata \
	&& \
	# Cleanup
	rm -rf \
		/var/cache/apk/

# Install app
COPY . /app/medusa/

# Ports and Volumes
EXPOSE 8081
VOLUME /config /downloads /tv /anime

WORKDIR /app/medusa
CMD [ "python", "start.py", "--nolaunch", "--datadir", "/config" ]
