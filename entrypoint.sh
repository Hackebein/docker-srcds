#!/bin/bash
set -eu

_sig () {
	export SIG=$1
	SIG_SHORT=$(echo ${SIG} | sed -e 's/^SIG//g')
	echo "Caught ${SIG} signal!"
	if [[ -x "./${SIG}_before.sh" ]]; then
		./${SIG}_before.sh
	fi
	kill -s ${SIG} ${PID}
	if [[ -x "./${SIG}_after.sh" ]]; then
		./${SIG}_before.sh
	fi
	wait "${PID}"
}

# install APPS
IFS=',' read -ra APPS <<< "${APPS}"
APP_4020=false
for a in "${APPS[@]}" ; do
	if [[ "${GAME}" == "garrysmod"  && "${a}" =~ ^4020(\s.*)?$ ]]; then
		APP_4020=${a}
	else
		steamcmd \
			+login ${LOGIN} \
			+force_install_dir "$(pwd)" \
			+app_update ${a} -validate -language en \
			+quit
	fi
done
# Workaround APPID 4020 (garrysmod)
if [[ "${APP_4020}" != "false" ]]; then
	steamcmd \
		+login ${LOGIN} \
		+force_install_dir "$(pwd)" \
		+app_update ${APP_4020} -validate -language en \
		+quit
	find $(pwd)/* -maxdepth 0 -type d -not -name 'bin' -and -not -name 'platform' -and -not -name 'sourceengine' -and -not -name 'steamapps' -and -not -name 'garrysmod' \
		| sed -E -n -e 's/^(.*+\/)(.*)$/    "\2" "\1\2"\r/p' \
		| ( \
			echo -ne '"mountcfg"\r\n{\r\n'; \
			cat; \
			echo -ne '}\r\n'; \
		) > garrysmod/cfg/mount.cfg
	find $(pwd)/* -maxdepth 0 -type d -not -name 'bin' -and -not -name 'platform' -and -not -name 'sourceengine' -and -not -name 'steamapps' -and -not -name 'garrysmod' \
		| sed -E -n -e 's/^(.*+\/)(.*)$/    "\2" "1"\r/p' \
		| ( \
			echo -ne '"gamedepotsystem"\r\n{\r\n'; \
			cat; \
			echo -ne '}\r\n'; \
		) > garrysmod/cfg/mountdepots.txt
fi

if [[ -n "${METAMOD}" ]]; then
	METAMOD_URL=$(set +e; jq -M -e -r '.["mmsource-" + env.METAMOD + "-linux"]' /opt/misc/alliedmods.json; set -e)
	if [[ "${METAMOD}" == "null" ]]; then
		echo "Can't found MetaMod version"
		METAMOD=
		METAMOD_URL=
	else
		echo "Found MetaMod ${METAMOD} (${METAMOD_URL})"
		METAMOD_FILE=$(echo "${METAMOD_URL}" | rev | cut -d'/' -f1 | rev)
		curl -s "${METAMOD_URL}" -o "/tmp/${METAMOD_FILE}"
		tar --no-same-owner --keep-newer-files -C "${GAME}" -xf "/tmp/${METAMOD_FILE}"
		rm "/tmp/${METAMOD_FILE}"
	fi
fi

if [[ -n "${METAMOD}" && -n "${SOURCEMOD}" ]]; then
	SOURCEMOD_URL=$(set +e; jq -M -e -r '.["sourcemod-" + env.SOURCEMOD + "-linux"]' /opt/misc/alliedmods.json; set -e)
	if [[ "${SOURCEMOD}" == "null" ]]; then
		echo "Can't found SourceMod version"
		SOURCEMOD=
		SOURCEMOD_URL=
	else
		echo "Found SourceMod ${SOURCEMOD} (${SOURCEMOD_URL})"
		SOURCEMOD_FILE=$(echo "${SOURCEMOD_URL}" | rev | cut -d'/' -f1 | rev)
		curl -s "${SOURCEMOD_URL}" -o "/tmp/${SOURCEMOD_FILE}"
		tar --no-same-owner --keep-newer-files -C "${GAME}" -xf "/tmp/${SOURCEMOD_FILE}"
		rm "/tmp/${SOURCEMOD_FILE}"
	fi
else
	SOURCEMOD=
fi

if [[ -n "${SOURCEMOD}" && -n "${STEAMWORKS}" ]]; then
	STEAMWORKS_URL=$(set +e; jq -M -e -r '.["SteamWorks-" + env.STEAMWORKS + "-linux"]' /opt/misc/alliedmods.json; set -e)
	if [[ "${STEAMWORKS}" == "null" ]]; then
		echo "Can't found SteamWorks version"
		STEAMWORKS=
		STEAMWORKS_URL=
	else
		echo "Found SteamWorks ${STEAMWORKS} (${STEAMWORKS_URL})"
		STEAMWORKS_FILE=$(echo "${STEAMWORKS_URL}" | rev | cut -d'/' -f1 | rev)
		curl -s "${STEAMWORKS_URL}" -o "/tmp/${STEAMWORKS_FILE}"
		tar --no-same-owner --keep-newer-files -C "${GAME}" -xf "/tmp/${STEAMWORKS_FILE}"
		rm "/tmp/${STEAMWORKS_FILE}"
	fi
else
	STEAMWORKS=
fi

if [[ -n "${SOURCEMOD}" ]]; then
	IFS=',' read -ra SOURCEMOD_PLUGINS_INSTALL <<< "${SOURCEMOD_PLUGINS_INSTALL}"
	for PLUGIN_URL in "${SOURCEMOD_PLUGINS_INSTALL[@]}"; do
		echo "Installing ${PLUGIN_URL}"
		PLUGIN_FILE=$(echo "${PLUGIN_URL}" | rev | cut -d'/' -f1 | rev)
		if [[ "${PLUGIN_URL}" =~ ^https?:\/\/ ]]; then
			curl -s "${PLUGIN_URL}" -o "/tmp/${PLUGIN_FILE}"
		elif [[ -f "${PLUGIN_URL}" ]]; then
			cp -a "${PLUGIN_URL}" "/tmp"
		else
			echo "Error: Unknown file source."
			exit 1
		fi
		# TODO: detect single file
		if [[ "${PLUGIN_FILE}" =~ \.smx$ ]]; then
			cp -a "/tmp/${PLUGIN_FILE}" "$(pwd)/${GAME}/addons/sourcemod/plugins/"
		elif [[ "$(set +e; tar -tzf "/tmp/${PLUGIN_FILE}" 2>/dev/null >/dev/null; echo $?; set -e)" == "0" ]]; then
			if [[ "$(tar -tzf "/tmp/${PLUGIN_FILE}" | grep '^addons/$' | wc -l)" == "1" ]]; then
				tar --no-same-owner --keep-newer-files -C "${GAME}" -xf "/tmp/${PLUGIN_FILE}"
			elif [[ "$(tar -tzf "/tmp/${PLUGIN_FILE}" | grep "^${GAME}/$" | wc -l)" == "1" ]]; then
				tar --no-same-owner --keep-newer-files -xf "/tmp/${PLUGIN_FILE}"
			else
				rm "/tmp/${PLUGIN_FILE}"
				echo "Error: Unknown archiv structure."
				exit 1
			fi
		elif [[ "$(set +e; unzip -Z1 "/tmp/${PLUGIN_FILE}" 2>/dev/null >/dev/null; echo $?; set -e)" == "0" ]]; then
			if [[ "$(unzip -Z1 "/tmp/${PLUGIN_FILE}" | grep '^addons/$' | wc -l)" == "1" ]]; then
				unzip -u -o -d "${GAME}" "/tmp/${PLUGIN_FILE}"
			elif [[ "$(unzip -Z1 "/tmp/${PLUGIN_FILE}" | grep "^${GAME}/$" | wc -l)" == "1" ]]; then
				unzip -u -o "/tmp/${PLUGIN_FILE}"
			else
				rm "/tmp/${PLUGIN_FILE}"
				echo "Error: Unknown archiv structure."
				exit 1
			fi
		else
			rm "/tmp/${PLUGIN_FILE}"
			echo "Error: Unknown file format."
			exit 1
		fi
		rm "/tmp/${PLUGIN_FILE}"
	done
fi

if [[ -d "/opt/overlay" ]]; then
	cp -a "/opt/overlay/." "$(pwd)"
fi

if [[ -n "${SOURCEMOD}" ]]; then
	mv "$(pwd)/${GAME}/addons/sourcemod/plugins/"*".smx" "$(pwd)/${GAME}/addons/sourcemod/plugins/disabled/"
	cp -a "/opt/misc/UpdateCheck.smx" "$(pwd)/${GAME}/addons/sourcemod/plugins/disabled/"
	IFS=',' read -ra SOURCEMOD_PLUGINS_ENABLE <<< "${SOURCEMOD_PLUGINS_ENABLE}"
	for a in "${SOURCEMOD_PLUGINS_ENABLE[@]}" ; do
		echo "Enable SourceMod Plugin ${a}"
		if [[ -f "$(pwd)/${GAME}/addons/sourcemod/plugins/disabled/${a}.smx" ]]; then
			mv "$(pwd)/${GAME}/addons/sourcemod/plugins/disabled/${a}.smx" "$(pwd)/${GAME}/addons/sourcemod/plugins/"
		else
			echo "Error: SourceMod Plugin ${a} not found."
			exit 1
		fi
	done
fi

if [[ -n "${SOURCEMOD}" && -n "${STEAMWORKS}" && "${AUTOUPDATE}" != "false" ]]; then
	mv "$(pwd)/${GAME}/addons/sourcemod/plugins/disabled/UpdateCheck.smx" "$(pwd)/${GAME}/addons/sourcemod/plugins/"
else
	AUTOUPDATE=false
fi

# GLST via API
if [[ -z "${GLST}" && -n "${GLSTAPP}" && -n "${AUTHKEY}" ]]; then
	echo "Try to created GLST"
	GLSTMEMO=${GLSTMEMO:-$(hostname)}
	IFS=- read STEAMID GLST <<<"$(curl \
		-s \
		-d "key=${AUTHKEY}&appid=${GLSTAPP}&memo=${GLSTMEMO}" \
		'https://api.steampowered.com/IGameServersService/CreateAccount/v1/' \
		| jq \
			-e \
			-r \
			-M '.response | "\(.steamid)-\(.login_token)"' \
	)"
	if [[ "${STEAMID}" =~ ^[0-9]+$ && "${GLST}" =~ ^[0-9A-F]+$ ]]; then
		echo "Created GLST: ${GLST} (${GLSTMEMO}) for APPID ${GLSTAPP}"
	else
		echo "GLST can't be created! Check your AUTHKEY, GLSTAPP and account requirements"
		STEAMID=
		GLST=
	fi
fi

if [[ "${SIGNALS_ENABLE}" == "true" ]]; then
	IFS=' ' read -r -a singals <<< $(kill -l | sed -e 's/[0-9]\+)//g' | tr -d '\t\r\n')
	for SIG in "${singals[@]}"; do
		SIG_SHORT=$(echo ${SIG} | sed -e 's/^SIG//g')
		echo "Register ${SIG} event"
		eval "trap '_sig ${SIG}' ${SIG_SHORT}"
	done
	./srcds_run \
		-strictportbind \
		-port "${PORT}" \
		-tv_port "${TVPORT}" \
		-clientport "${CLIENTPORT}" \
		-sport "${SPORT}" \
		+sv_setsteamaccount "${GLST}" \
		"$(eval "echo ${SRCDSPARAMS}")" \
		"${@}" &

	export PID=$!

	wait "${PID}"
else
	./srcds_run \
		-strictportbind \
		-port "${PORT}" \
		-tv_port "${TVPORT}" \
		-clientport "${CLIENTPORT}" \
		-sport "${SPORT}" \
		+sv_setsteamaccount "${GLST}" \
		"$(eval "echo ${SRCDSPARAMS}")" \
		"${@}"
fi

if [ -n "${STEAMID}" ]; then
	curl \
		-s \
		-o /dev/null \
		-d "key=${AUTHKEY}&steamid=${STEAMID}" \
		'https://api.steampowered.com/IGameServersService/DeleteAccount/v1/'
fi
