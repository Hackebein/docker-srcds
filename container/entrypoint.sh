#!/bin/bash

PORT=${PORT:-27015}
TVPORT=${TVPORT:-27020}
CLIENTPORT=${CLIENTPORT:-27005}
SPORT=${SPORT:-26900}
SRCDSPARAMS=${SRCDSPARAMS:-}

APPS=${APPS:-244310}
for a in "${APPS[@]}" ; do
	steamcmd \
		+login anonymous \
		+force_install_dir "${BASEDIR}" \
		+app_update "${a}" -validate -language en \
		+quit
done

./srcds_run \
	-strictportbind \
	-port "${PORT}" \
	-tv_port "${TVPORT}" \
	-clientport "${CLIENTPORT}" \
	-sport "${SPORT}" \
	"${SRCDSPARAMS}" \
	"${@}"