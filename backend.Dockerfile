# syntax=docker/dockerfile:1
ARG GO_VERSION=1.19
FROM golang:${GO_VERSION} AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
WORKDIR /app/src
RUN go build -o /bin/server

FROM alpine:latest AS final

RUN --mount=type=cache,target=/var/cache/apk \
    apk --update add \
        ca-certificates \
        tzdata \
        libc6-compat \
        && \
        update-ca-certificates

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

COPY --from=build /bin/server /bin/

EXPOSE 8888

CMD ["/bin/server"]
