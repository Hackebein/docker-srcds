FROM hackebein/steamcmd

ARG BASEDIR=/opt/steam
ONBUILD ARG BASEDIR=$BASEDIR
ENV BASEDIR=$BASEDIR

RUN apt update \
 && apt install -y \
		curl \
        jq \
 && apt clean
COPY container/* $BASEDIR/

EXPOSE 27015/tcp 27015/udp 27020/udp

WORKDIR $BASEDIR

ENTRYPOINT ["bash", "entrypoint.sh"]
