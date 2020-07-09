FROM golang:latest

MAINTAINER LightServer "w@lightserver.cn"

WORKDIR $GOPATH/src

COPY . $GOPATH/src/demo

EXPOSE 8088

ENTRYPOINT ["/bin/bash", "/go/src/demo/script/build.sh"]