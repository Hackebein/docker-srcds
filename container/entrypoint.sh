#!/bin/bash

PORT=${PORT:-27015}
TVPORT=${TVPORT:-27020}
CLIENTPORT=${CLIENTPORT:-27005}
SPORT=${SPORT:-26900}
SRCDSPARAMS=${SRCDSPARAMS:-}
AUTHKEY=${AUTHKEY:-}
GLST=${GLST:-}
GLSTAPP=${GLSTAPP:-}
GLSTMEMO=${GLSTMEMO:-$(hostname)}

APPS=${APPS:-244310}
IFS=',' read -ra APPS <<< "$APPS"
for a in "${APPS[@]}" ; do
	steamcmd \
		+login anonymous \
		+force_install_dir "${BASEDIR}" \
		+app_update "${a}" -validate -language en \
		+quit
done

if [[ -z "${GLST}" && -n "${GLSTAPP}" && -n "${AUTHKEY}" ]]; then
	echo "Try to created GLST"
	IFS=- read STEAMID GLST <<<"$(curl \
		-s \
		-d "key=${AUTHKEY}&appid=${GLSTAPP}&memo=${GLSTMEMO}" \
		'https://api.steampowered.com/IGameServersService/CreateAccount/v1/' \
		| jq \
			-e \
			-r '.response | "\(.steamid)-\(.login_token)"' \
	)"
	if [[ "${STEAMID}" =~ ^[0-9]+$ && "${GLST}" =~ ^[0-9A-F]+$ ]]; then
		echo "Created GLST: ${GLST} (${GLSTMEMO}) for APPID ${GLSTAPP}"
	else
		echo "GLST can't be created! Check your AUTHKEY, GLSTAPP and account requirements"
		STEAMID=
		GLST=
	fi
fi

./srcds_run \
	-strictportbind \
	-port "${PORT}" \
	-tv_port "${TVPORT}" \
	-clientport "${CLIENTPORT}" \
	-sport "${SPORT}" \
	+sv_setsteamaccount "${GLST}" \
	"$(eval "echo ${SRCDSPARAMS}")" \
	"${@}"

if [ -n "${STEAMID}" ]; then
	curl \
		-s \
		-d "key=${AUTHKEY}&steamid=${STEAMID}" \
		'https://api.steampowered.com/IGameServersService/DeleteAccount/v1/'
fi
