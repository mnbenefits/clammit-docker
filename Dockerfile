FROM golang:alpine AS build-env
ENV CGO_ENABLED 0
WORKDIR /app
RUN apk add --no-cache git ca-certificates make cmake
ENV GOBIN=/app/bin
RUN git clone https://github.com/ifad/clammit . && make all

# Build runtime image
FROM alpine:latest
RUN apk --no-cache add ca-certificates && \
    addgroup -S clam && adduser -u 100 -S -G clam clam

RUN mkdir -m 777 -p /home/clam && chmod 777 /home/clam

USER clam

WORKDIR /home/clam

COPY --chmod=777 --chown=clam:clam launcher.sh /home/clam


COPY --from=build-env --chown=clam:clam /app/bin/clammit .
COPY --from=build-env --chown=clam:clam /app/testfiles ./testfiles

ENTRYPOINT ["sh", "/home/clam/launcher.sh", "/home/clam/clammit.cfg", "/home/clam/clammit", "-config", "clammit.cfg"]

