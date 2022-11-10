############################################################
# Dockerfile that builds a Necesse Gameserver
############################################################
FROM docker.io/cm2network/steamcmd:root

LABEL maintainer="robbmanes@protonmail.com"

ENV USER steam
ENV STEAMAPPID 1169370
ENV STEAMAPP Necesse
ENV HOMEDIR "/home/${USER}/"
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated/"
ENV GAMEDATADIR "${HOMEDIR}/.config/Necesse/"
ENV DEFAULTCONFIG "${HOMEDIR}/default_config/"

USER root
COPY scripts/entry.sh ${HOMEDIR}
ADD default_config ${HOMEDIR}/default_config
RUN mkdir -p "${STEAMAPPDIR}" "${GAMEDATADIR}" \
	&& chmod -R 755 "${HOMEDIR}" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}"

USER ${USER}
ENV PORT=14159

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 14159/udp
VOLUME ${GAMEDATADIR}
