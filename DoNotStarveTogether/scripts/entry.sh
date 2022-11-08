#!/bin/bash

# Large portions adapted from official server entrypoint scripts and forums.
# https://accounts.klei.com/assets/gamesetup/linux/run_dedicated_servers.sh
# https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/

# Server information must be provided *even on first start*.
# See the above forum and this link to configure your server initially:
# https://accounts.klei.com/account/game/servers?game=DontStarveTogether

function fail()
{
	echo Error: "$@" >&2
	echo "Ensure that you have properly configured the GAMEDATADIR path to point to your server's game data."
	echo "Alternatvely make sure you have mounted the proper volume at ~/.klei/DoNotStarveTogether/."
	echo "If this is your first time running this, you can get server configuration by following the instructions here:"
	echo "https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/"
	exit 1
}

function check_for_file()
{
	if [ ! -e "$1" ]; then
		fail "Missing file: $1"
	fi
}

if [ -n "${STEAM_BETA_BRANCH}" ]
then
	echo "Loading Steam Beta Branch"
	bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
					+login anonymous \
					+app_update "${STEAM_BETA_APP}" \
					-beta "${STEAM_BETA_BRANCH}" \
					-betapassword "${STEAM_BETA_PASSWORD}" \
					+quit
else
	echo "Loading Steam Release Branch"
	bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
					+login anonymous \
					+app_update "${STEAMAPPID}" \
					+quit
fi

echo "Clearing Mods..."
# Clear all workshop mods:
# find all folders / files in mods folder which are numeric only;
# remove the workshop mods
find "${MODPATH}"/* -maxdepth 0 -regextype posix-egrep -regex ".*/[[:digit:]]+" | xargs -0 -d"\n" rm -R 2>/dev/null

# Install mods (if defined)
declare -a MODS="${MODS}"
if (( ${#MODS[@]} ))
then
	echo "Installing Mods..."
	for MODID in "${MODS[@]}"; do
		echo "> Install mod '${MODID}'"
		"${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" +login anonymous +workshop_download_item "${WORKSHOPID}" "${MODID}" +quit

		echo -e "\n> Link mod content '${MODID}'"
		ln -s "${STEAMAPPDIR}/steamapps/workshop/content/${WORKSHOPID}/${MODID}" "${MODPATH}/${MODID}"
	done
fi

# Begin startup
check_for_file "${GAMEDATADIR}/cluster.ini"
check_for_file "${GAMEDATADIR}/cluster_token.txt"
check_for_file "${GAMEDATADIR}/Master/server.ini"
check_for_file "${GAMEDATADIR}/Caves/server.ini"
check_for_file "${STEAMAPPDIR}/bin64"

cd "${STEAMAPPDIR}/bin64" || fail

run_shared=(./dontstarve_dedicated_server_nullrenderer_x64)
run_shared+=(-console)
run_shared+=(-cluster "${CLUSTERNAME}")
run_shared+=(-monitor_parent_process $$)

"${run_shared[@]}" -shard Caves  | sed 's/^/Caves:  /' &
"${run_shared[@]}" -shard Master | sed 's/^/Master: /'
