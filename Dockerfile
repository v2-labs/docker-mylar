FROM alpine:3.9
MAINTAINER Juvenal A. Silva Jr. <juvenal.silva.jr@gmail.com>

# Create user and group for Mylar.
RUN addgroup -S -g 666 mylar \
 && adduser -S -u 666 -G mylar -h /home/mylar -s /bin/sh mylar

# This is Mylar basic install with requirements
RUN apk add --no-cache ca-certificates openssl python py-pip py-six py-cryptography \
                       py-enum34 py-openssl py-cheetah py-pillow zlib shadow git \
 && pip --no-cache-dir install --upgrade comictagger \
                                         configparser \
                                         html5lib \
                                         requests\
                                         tzlocal \
 && cd /opt \
 && git clone https://github.com/evilhero/mylar.git mylar \
 && mkdir -p /mnt/comics \
 && mkdir -p /mnt/downloads \
 && mkdir -p /mnt/torrents \
 && mkdir -p /mnt/data

# Add Mylar init script.
COPY entrypoint.sh /home/mylar/entrypoint.sh
RUN chmod 755 /home/mylar/entrypoint.sh

VOLUME ["/mnt/comics", "/mnt/downloads", "/mnt/torrents" "/mnt/data"]

EXPOSE 8090

WORKDIR /home/mylar

CMD ["./entrypoint.sh"]
