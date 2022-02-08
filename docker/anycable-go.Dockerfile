FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y curl

RUN curl -L -o /usr/bin/anycable-go https://github.com/anycable/anycable-go/releases/download/v1.2.0/anycable-go-linux-amd64 && \
    chmod +x /usr/bin/anycable-go

RUN ulimit -n 1000000
RUN sysctl -w fs.file-max=1000000
RUN sysctl -w fs.nr_open=1000000
RUN sysctl -p /etc/sysctl.conf

ENTRYPOINT ["/usr/bin/anycable-go"]
