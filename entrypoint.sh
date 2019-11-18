#!/bin/bash

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
	GLSTMEMO=${GLSTMEMO:-$(hostname)}
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
