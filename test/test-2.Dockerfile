FROM alpine:latest

LABEL maintainer="Unbounded Tech"
LABEL description="Test 2 Alpine container"

RUN apk update && \
    apk add --no-cache bash && \
    rm -rf /var/cache/apk/*

CMD ["echo", "Hello from test-2 container"]