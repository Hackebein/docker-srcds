FROM hackebein/steamcmd
ENV SIGNALS_ENABLE="false" \
	PORT="27015" \
	TVPORT="27020" \
	CLIENTPORT="27005" \
	SPORT="26900" \
	# App
	APPS="244310" \
	GAME="" \
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
	# Login credentials
	LOGIN="anonymous" \
	#
	# MetaMod
	METAMOD="" \
	#
	# SourceMod
	SOURCEMOD="" \
	SOURCEMOD_PLUGINS_INSTALL="" \
	SOURCEMOD_PLUGINS_ENABLE="admin-flatfile,adminhelp,adminmenu,antiflood,basebans,basechat,basecomm,basecommands,basetriggers,basevotes,clientprefs,funcommands,funvotes,nextmap,playercommands,reservedslots,sounds" \
	#
	# SteamWorks
	STEAMWORKS="latest" \
	#
	# Update
	AUTOUPDATE="false" \
	#
	# Workshop client download (require API, only garrysmod)
	WORKSHOPDL="" \
	#
	# Other
	CUSTOMPARAMETERS="" \
	#
	# Start parameters
	SRCDSPARAMS="\
		\${CUSTOMPARAMETERS} \
	"
COPY entrypoint.sh /
COPY misc /opt/misc
RUN apt update \
 && apt install -y \
        curl \
        jq \
        lib32stdc++6 \
        unzip \
 && apt clean \
 && rm -rf \
        /var/lib/apt/lists/* \
 && chmod +x /entrypoint.sh
EXPOSE 27015/tcp 27015/udp 27020/udp
WORKDIR /opt/steam
VOLUME /opt/steam
ENTRYPOINT ["/entrypoint.sh"]
