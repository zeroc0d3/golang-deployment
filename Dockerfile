### Builder ###
FROM golang:1.19.5-alpine3.17 as builder

WORKDIR /go/src/app
ENV GIN_MODE=release
ENV GOPATH=/go

RUN apk add --no-cache \
        build-base \
        git \
        curl \
        make \
        bash

COPY src /go/src/app

RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
    cd /go/src/app && \
        go build -mod=readonly -ldflags="-s -w" -o goapp

### Binary ###
FROM golang:1.19.5-alpine3.17

ARG BUILD_DATE
ARG BUILD_VERSION
ARG GIT_COMMIT
ARG GIT_URL

ENV VENDOR="DevOpsCornerId"
ENV AUTHOR="DevOpsCorner.id <support@devopscorner.id>"
ENV IMG_NAME="alpine"
ENV IMG_VERSION="3.17"
ENV IMG_DESC="Docker GO App Alpine 3.17"
ENV IMG_ARCH="amd64/x86_64"

ENV ALPINE_VERSION="3.17"
ENV GIN_MODE=release
ENV APP_URL=${APP_URL:-http://localhost}
ENV APP_PORT=${APP_PORT:-8080}
ENV DB_CONNECTION=${DB_CONNECTION:-sqlite}
ENV DB_REGION=${DB_REGION:-us-west-2}
ENV DB_HOST=${DB_HOST:-localhost}
ENV DB_PORT=${DB_PORT}
ENV DB_DATABASE=${DB_DATABASE:-go-bookstore.db}
ENV DB_USERNAME=${DB_USERNAME:-root}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV JWT_AUTH_USERNAME=${JWT_AUTH_USERNAME:-devopscorner}
ENV JWT_AUTH_PASSWORD=${JWT_AUTH_PASSWORD:-DevOpsCorner@2023}
ENV JWT_SECRET=${JWT_SECRET:-s3cr3t}

LABEL maintainer="$AUTHOR" \
        architecture="$IMG_ARCH" \
        ubuntu-version="$ALPINE_VERSION" \
        org.label-schema.build-date="$BUILD_DATE" \
        org.label-schema.name="$IMG_NAME" \
        org.label-schema.description="$IMG_DESC" \
        org.label-schema.vcs-ref="$GIT_COMMIT" \
        org.label-schema.vcs-url="$GIT_URL" \
        org.label-schema.vendor="$VENDOR" \
        org.label-schema.version="$BUILD_VERSION" \
        org.label-schema.schema-version="$IMG_VERSION" \
        org.opencontainers.image.authors="$AUTHOR" \
        org.opencontainers.image.description="$IMG_DESC" \
        org.opencontainers.image.vendor="$VENDOR" \
        org.opencontainers.image.version="$IMG_VERSION" \
        org.opencontainers.image.revision="$GIT_COMMIT" \
        org.opencontainers.image.created="$BUILD_DATE" \
        fr.hbis.docker.base.build-date="$BUILD_DATE" \
        fr.hbis.docker.base.name="$IMG_NAME" \
        fr.hbis.docker.base.vendor="$VENDOR" \
        fr.hbis.docker.base.version="$BUILD_VERSION"

WORKDIR /go

COPY --from=builder /go/src/app/goapp /go/goapp
COPY src /go/src
COPY src/.env.example /go/.env
COPY entrypoint.sh /go/entrypoint

ENTRYPOINT ["/go/goapp"]
EXPOSE 80 443 8080
