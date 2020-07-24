FROM ubuntu:18.04

ENV ANSIBLE_VERSION=2.8.6
ENV OVFTOOL_FILE="VMware-ovftool-4.3.0-13981069-lin.x86_64.bundle"

COPY $OVFTOOL_FILE /tmp/

RUN set -xe \
    && echo "****** Install system dependencies ******" \
    && apt update \
    && apt install -y --no-install-recommends \
       locales curl \
       software-properties-common libssl-dev libffi-dev \
       wget rsyslog systemd systemd-cron sudo iproute2 \
       xorriso ca-certificates iputils-ping unzip \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

RUN set -xe \
    && echo "****** Install Python bits ******" \
    && apt update \
    && apt install -y --no-install-recommends \
       locales curl \
       python3-setuptools build-essential libssl-dev libffi-dev \
       python3-pip python3-dev \
    && pip3 install ansible pyvmomi\
    && apt remove -y build-essential python3-setuptools python3-pip python3-dev python3-distutils \
    && apt autoremove -y \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

RUN /bin/sh /tmp/$OVFTOOL_FILE --console --required --eulas-agreed \
    && rm -f $OVFTOOL_FILENAME
