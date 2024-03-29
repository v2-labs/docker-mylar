FROM alpine:3.9
MAINTAINER Juvenal A. Silva Jr. <juvenal.silva.jr@gmail.com>

# Create user and group for Mylar.
RUN addgroup -S -g 666 mylar \
 && adduser -S -u 666 -G mylar -h /home/mylar -s /bin/sh mylar

# This is Mylar basic install with requirements
RUN apk add --no-cache ca-certificates openssl python py-pip py-six py-cryptography \
                       py-enum34 py-openssl py-cheetah py-pillow zlib shadow \
 && pip --no-cache-dir install -U comictagger==1.1.32rc1 \
                                  configparser \
                                  html5lib \
                                  requests\
                                  tzlocal \
 && cd /opt \
 && wget -O- https://github.com/evilhero/mylar/archive/master.tar.gz | tar -zx \
 && mv -v mylar-master mylar \
 && mkdir -p /etc/mylar \
 && mkdir -p /mnt/mylar/comics \
 && mkdir -p /mnt/mylar/downloads \
 && mkdir -p /mnt/mylar/torrents

# Add Mylar init script.
COPY entrypoint.sh /home/mylar/entrypoint.sh
RUN chmod 755 /home/mylar/entrypoint.sh

VOLUME ["/etc/mylar", "/mnt/mylar/comics", "/mnt/mylar/downloads", "/mnt/mylar/torrents"]

EXPOSE 8090

WORKDIR /home/mylar

CMD ["./entrypoint.sh"]
