FROM hackebein/steamcmd

ARG BASEDIR=/opt/steam
ONBUILD ARG BASEDIR=$BASEDIR
ENV BASEDIR=$BASEDIR \
	SIGNALS_ENABLE="true" \
	PORT="27015" \
	TVPORT="27020" \
	CLIENTPORT="27005" \
	SPORT="26900" \
	# App
	APPS="244310" \
	#
	# API
	# http://steamcommunity.com/dev/apikey
	AUTHKEY="" \
	#
	# Public access
	# automatic via API
	GLSTAPP="244310" \
	# manual
	# APPID: 244310
	# http://steamcommunity.com/dev/managegameservers
	GLST="" \
	#
	# Other
	CUSTOMPARAMETERS="" \
	#
	# Start parameters
	SRCDSPARAMS="\
		\${CUSTOMPARAMETERS} \
	"

RUN apt update \
 && apt install -y \
		curl \
		jq \
 && apt clean
COPY container/* $BASEDIR/

EXPOSE 27015/tcp 27015/udp 27020/udp

WORKDIR $BASEDIR

ENTRYPOINT ["bash", "entrypoint.sh"]
