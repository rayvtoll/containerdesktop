# machine om thema spul in te gooien
FROM debian:sid-slim as gitmachine
MAINTAINER "Ray van Toll"
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/B00merang-Project/Windows-10.git /tmp/themes/Windows-10
RUN git clone https://github.com/B00merang-Artwork/Windows-10.git /tmp/icons/Windows-10

# de uiteindelijke container
FROM ubuntu as system
MAINTAINER "Ray van Toll"
ENV DEBIAN_FRONTEND nonintractive 
#ENV LANG="en_US.UTF-8"
RUN apt-get update -y && apt-get install -y --no-install-recommends \
	metacity \
	lxde \
	gtk2-engines \
	gtk2-engines-murrine \
	supervisor \
	xrdp \
	xdg-user-dirs
RUN apt-get install -y \
	xserver-xorg \
	xorgxrdp \
	ssh \
	curl

# timezonecrap
RUN apt-get install -y tzdata

# aanmaken benodigde directories 
RUN mkdir -p \
	/usr/share/icons/Windows-10/ \
	/usr/share/themes/Windows-10/ \
        /etc/skel/.config/pcmanfm/LXDE/ \
	/tmp/desktop 

# kopieren files van tijdelijke machine
#COPY --from=gitmachine /tmp/themes/Windows-10/unity/modes/launcher_bfb.png /tmp/
COPY --from=gitmachine /tmp/themes/Windows-10/ /usr/share/themes/Windows-10
COPY --from=gitmachine /tmp/icons/Windows-10/ /usr/share/icons/Windows-10

# wat errors voorkomen
RUN echo "session required pam_loginuid.so" >> /etc/pam.d/lxdm
RUN echo "session required pam_systemd.so" >> /etc/pam.d/lxdm

# .bashrc verrijken met externe applicatie containers
RUN echo "source ~/.containers" >> /etc/skel/.bashrc

# aanmaken wachtwoord voor dev doeleinden
RUN echo "root:root" | chpasswd
RUN xrdp-keygen xrdp auto

# kopieren van benodigde bestanden naar container
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

# rdp poort open en starten
EXPOSE 3389
CMD ["sh", "/entrypoint.sh"] 
