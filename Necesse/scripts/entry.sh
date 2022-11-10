#!/bin/bash

function log()
{
	DATESTRING="[$(date +%T)]"
	echo "${DATESTRING}: ${@}" >&2
}

function fail()
{
	log "Error: ${@} >&2"
	exit 1
}

function check_for_file()
{
	if [ ! -e "$1" ]; then
		fail "Missing file: $1"
	fi
}

function install_or_update()
{
	if [ -n "${STEAM_BETA_BRANCH}" ]
	then
		log "Loading Steam Beta Branch"
		bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
						+login anonymous \
						+app_update "${STEAM_BETA_APP}" \
						-beta "${STEAM_BETA_BRANCH}" \
						-betapassword "${STEAM_BETA_PASSWORD}" \
						+quit
	else
		log "Loading Steam Release Branch"
		bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
						+login anonymous \
						+app_update "${STEAMAPPID}" \
						+quit
	fi
}

function handle_mods()
{
	log "Clearing Existing Mods..."
	# Clear all workshop mods:
	# find all folders / files in mods folder which are numeric only;
	# remove the workshop mods
	find "${MODPATH}"/* -maxdepth 0 -regextype posix-egrep -regex ".*/[[:digit:]]+" | xargs -0 -d"\n" rm -R 2>/dev/null

	# Install mods (if defined)
	declare -a MODS="${MODS}"
	if (( ${#MODS[@]} ))
	then
		log "Installing Mods..."
		for MODID in "${MODS[@]}"; do
			log "> Installing mod '${MODID}'"
			"${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" +login anonymous +workshop_download_item "${WORKSHOPID}" "${MODID}" +quit

			log "\n> Link mod content '${MODID}'"
			ln -s "${STEAMAPPDIR}/steamapps/workshop/content/${WORKSHOPID}/${MODID}" "${MODPATH}/${MODID}"
		done
	fi
}

function check_existing_config()
{
	if [ "$(ls -A $GAMEDATADIR)" ]; then
		log "Existing files found in ${GAMEDATADIR}, proceeding."
		return
	else
		log "No files found in ${GAMEDATADIR}, copying default configuration."
		mkdir -p ${GAMEDATADIR}/
		cp -r ${DEFAULTCONFIG}/* ${GAMEDATADIR}/
	fi
}

function start_app()
{
	cd "${STEAMAPPDIR}/" || fail
	run_cmd=(./StartServer-nogui.sh)
	run_cmd+=(-localdir=${GAMEDATADIR})
	"${run_cmd}"
}

function main()
{
	install_or_update
	handle_mods
	check_existing_config
	start_app
}

main
