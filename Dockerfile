FROM hackebein/steamcmd
ENV SIGNALS_ENABLE="false" \
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
	#
	# APPID: 244310
	# http://steamcommunity.com/dev/managegameservers
	GLST="" \
	#
	# Login credentials
	LOGIN="anonymous" \
	#
	# Other
	CUSTOMPARAMETERS="" \
	#
	# Start parameters
	SRCDSPARAMS="\
		\${CUSTOMPARAMETERS} \
	"
COPY entrypoint.sh /
RUN apt update \
 && apt install -y \
        curl \
        jq \
 && apt clean \
 && rm -rf \
        /var/lib/apt/lists/* \
 && chmod +x /entrypoint.sh
EXPOSE 27015/tcp 27015/udp 27020/udp
WORKDIR $BASEDIR
ENTRYPOINT ["/entrypoint.sh"]
