FROM anycable/anycable-go AS anycable-go

FROM ubuntu:20.04

COPY --from=anycable-go /usr/local/bin/anycable-go /usr/local/bin/anycable-go

RUN ulimit -n 1000000
RUN sysctl -w fs.file-max=1000000
RUN sysctl -w fs.nr_open=1000000
RUN sysctl -p /etc/sysctl.conf

ENTRYPOINT ["/usr/local/bin/anycable-go"]
