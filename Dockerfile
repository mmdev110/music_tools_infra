FROM alpine:latest
WORKDIR /src/
RUN apk add --no-cache terraform && \
        apk add --no-cache git
ADD ./ /src/
#元イメージのENTRYPOINTを無効化
ENTRYPOINT []