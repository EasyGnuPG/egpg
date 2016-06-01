FROM ubuntu:16.04

RUN apt-get update; apt-get -y upgrade
RUN apt-get -y install \
        gnupg2 pinentry-tty haveged libgfshare-bin parcimonie \
        qrencode imagemagick zbar-tools wget
RUN useradd -m testuser
