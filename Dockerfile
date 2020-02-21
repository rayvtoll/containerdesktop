# Container voor installatie
FROM ubuntu as system
ENV DEBIAN_FRONTEND nonintractive 
#ENV LANG="en_US.UTF-8"
RUN apt-get update -y && apt-get install -y --no-install-recommends \
	metacity \
	lxde \
	gtk2-engines \
	gtk2-engines-murrine \
	supervisor \
	xrdp \
	xdg-user-dirs \
	xserver-xorg \
	xorgxrdp \
	ssh \
	curl

# timezonecrap
RUN apt-get install -y tzdata

# verwijderen default thema's en icoontjes
RUN rm -rf /usr/share/themes
RUN cp -r /usr/share/icons/hicolor /tmp/hicolor
RUN rm -rf /usr/share/icons

# aanmaken benodigde directories 
RUN mkdir -p \
	/usr/share/themes/ \
	/usr/share/icons/ \
    /etc/skel/.config/pcmanfm/LXDE/ \
	/tmp/desktop 

RUN cp -r /tmp/hicolor /usr/share/icons/hicolor

# wat errors voorkomen
RUN echo "session required pam_loginuid.so" >> /etc/pam.d/lxdm
RUN echo "session required pam_systemd.so" >> /etc/pam.d/lxdm

# .bashrc verrijken met externe applicatie containers
RUN echo "source ~/.containers" >> /etc/skel/.bashrc

# aanmaken wachtwoord voor dev doeleinden
RUN echo "root:root" | chpasswd
RUN xrdp-keygen xrdp auto

# kopieren van benodigde bestanden naar container
ADD ./themes/Windows-10 /usr/share/themes/Windows-10
ADD ./icons/Windows-10 /usr/share/icons/Windows-10
ADD ./.containers /etc/skel/
ADD ./mimeapps.list /etc/skel/.config/
ADD ./apps/* /usr/share/applications/
ADD ./panel /etc/xdg/lxpanel/LXDE/panels/
ADD ./entrypoint.sh /
ADD ./desktop.conf /etc/xdg/lxsession/LXDE/
ADD ./1.jpg /tmp/windows_10.jpg
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./pcmanfm.conf /etc/xdg/pcmanfm/LXDE/pcmanfm.conf
RUN cp /usr/share/themes/Windows-10/unity/modes/launcher_bfb.png /usr/share/lxde/images/lxde-icon.png

# rotzooi weg
RUN apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* 

# de 2e container voor kleiner formaat
FROM ubuntu as system2
COPY --from=system entrypoint.sh entrypoint.sh
COPY --from=system /etc /etc
COPY --from=system /tmp/windows_10.jpg /tmp/windows_10.jpg
COPY --from=system /lib /lib
COPY --from=system /proc /proc
COPY --from=system /sys /sys
COPY --from=system /usr /usr
COPY --from=system /var/log/supervisor /var/log/supervisor

# rdp poort open en starten
EXPOSE 3389
CMD ["sh", "/entrypoint.sh"] 
