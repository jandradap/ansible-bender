FROM centos:centos7.6.1810

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
			org.label-schema.name="alpine-bender" \
			org.label-schema.description="ansible-bender for CI/CD" \
			org.label-schema.url="http://andradaprieto.es" \
			org.label-schema.vcs-ref=$VCS_REF \
			org.label-schema.vcs-url="https://github.com/jandradap/alpine-bender" \
			org.label-schema.vendor="Jorge Andrada Prieto" \
			org.label-schema.version=$VERSION \
			org.label-schema.schema-version="1.0" \
			maintainer="Jorge Andrada Prieto <jandradap@gmail.com>" \
			org.label-schema.docker.cmd=""

RUN yum -y install epel-release \
    && yum install -y \
        git \
        gcc \
        wget \
        curl \
        openssl-devel \
        buildah \
        podman \
        python36u \
        python36-libs \
        python36-devel \
        python36-pip \
        python-virtualenv \
    && yum clean all

RUN virtualenv -p /usr/bin/python3 /root/python3env

RUN source /root/python3env/bin/activate \
    && pip install --upgrade pip \
    && pip3 install pipenv ansible-bender ansible

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;


COPY rootfs/entrypoint.sh /

RUN sed -i "s/driver = \"overlay\"/driver = \"vfs\"/g" /etc/containers/storage.conf \
    && sed -i '/^mountopt =.*/d' /etc/containers/storage.conf \
    && sed -i "s/cgroup_manager = \"systemd\"/cgroup_manager = \"cgroupfs\"/g" /usr/share/containers/libpod.conf \
    && sed -i "s/# events_logger = \"journald\"/events_logger = \"file\"/g" /usr/share/containers/libpod.conf \
    && cp -a /usr/share/containers/libpod.conf /etc/containers/ \
    && sed -i "s/cgroup_manager = \"systemd\"/cgroup_manager = \"cgroupfs\"/g" /etc/containers/libpod.conf \
    && chmod +x /entrypoint.sh

WORKDIR /usr/src

VOLUME ["/sys/fs/cgroup"]

VOLUME ["/usr/src"]

ENTRYPOINT ["/entrypoint.sh"]