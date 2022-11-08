############################################################
# Dockerfile that builds a Don't Starve Together Gameserver
############################################################
FROM docker.io/cm2network/steamcmd:root

LABEL maintainer="robbmanes@protonmail.com"

ENV STEAMAPPID 343050
ENV STEAMAPP dst
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV CLUSTERTOKEN ""
ENV GAMEDATADIR "${HOMEDIR}/.klei/DoNotStarveTogether/"

USER root
RUN dpkg --add-architecture i386 \
	&& apt-get update -y \
	&& apt-get install -y --no-install-recommends \
		libstdc++6 \
		libgcc1:i386 \
		libcurl4-gnutls-dev \
	&& apt-get clean \
	&& rm -rf \
		/tmp/* \
		/var/tmp/* \
		/var/lib/apt/lists/*

COPY scripts/entry.sh ${HOMEDIR}
RUN set -x \
	&& mkdir -p "${STEAMAPPDIR}" \
        && mkdir -p "${GAMEDATADIR}" \
	&& chmod 755 "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" \
	&& chown "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}"

USER ${USER}
ENV PORT=10999

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 10999/udp
