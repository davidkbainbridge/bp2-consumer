FROM alpine:3.2
MAINTAINER David Bainbridge <dbainbri.ciena@gmail.com>
ADD bp2-consumer-docker /root/bp2-consumer

ENV SBIS=string
ENV BP_HOOK_URL_REDIRECT_SOUTHBOUND_UPDATE=http://127.0.0.1:6789/api/v1/hook/southbound-update

ADD bp2/hooks /bp2/hooks

RUN ln -s /bp2/hooks/hook-to-rest /bp2/hooks/southbound-update

ENTRYPOINT ["/root/bp2-consumer"]
