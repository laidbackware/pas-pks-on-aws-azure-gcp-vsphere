FROM alpine:latest

ENV ANSIBLE_VERSION=2.8.5
ENV OVFTOOL_FILE="VMware-ovftool-4.3.0-13981069-lin.x86_64.bundle"

COPY $OVFTOOL_FILE /tmp/

RUN set -xe \
    && echo "****** Install system dependencies ******" \
    && apk add --no-cache --progress python3 openssl xorriso \
		ca-certificates git openssh sshpass tar gzip sed gawk bash  \
	&& apk --update add --virtual build-dependencies \
		python3-dev libffi-dev openssl-dev build-base  \
	\
	&& echo "****** Install ansible and python dependencies ******" \
    && pip3 install --upgrade pip \
	&& pip3 install ansible==${ANSIBLE_VERSION} pyvmomi \
    \
    && echo "****** Remove unused system librabies ******" \
	&& apk del build-dependencies \
	&& rm -rf /var/cache/apk/* 

RUN /bin/sh /tmp/$OVFTOOL_FILE --console --required --eulas-agreed \
	&& rm -f $OVFTOOL_FILENAME

#ncurses-compat

# RUN chmod +x /tmp/VMware-ovftool-*.bundle && echo -e "/w00t\n" >> /tmp/answer \
# 	/tmp/VMware-ovftool-*.bundle --eulas-agreed --required --console < /tmp/answer \
# 	&& rm /tmp/VMware-ovftool-*.bundle