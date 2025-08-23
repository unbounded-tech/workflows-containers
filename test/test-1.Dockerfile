FROM alpine:latest

LABEL maintainer="Unbounded Tech"
LABEL description="Test 1 Alpine container"

RUN apk update && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

CMD ["echo", "Hello from test-1 container"]