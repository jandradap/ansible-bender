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
    && yum install -y buildah \
        podman \
        python36u \
        python36-libs \
        python36-devel \
        python36-pip \
        git \
        gcc \
        openssl-devel \
        python-virtualenv \
    && yum clean all

RUN virtualenv -p /usr/bin/python3 /root/python3env

RUN source /root/python3env/bin/activate \
    && pip install --upgrade pip \
    && pip3 install pipenv ansible-bender ansible

RUN sed -i "s/driver = \"overlay\"/driver = \"vfs\"/g" /etc/containers/storage.conf \
    && sed -i '/^mountopt =.*/d' /etc/containers/storage.conf \
    && sed -i "s/cgroup_manager = \"systemd\"/cgroup_manager = \"cgroupfs\"/g" /usr/share/containers/libpod.conf \
    && cp -a /usr/share/containers/libpod.conf /etc/containers/ \
    && sed -i "s/cgroup_manager = \"systemd\"/cgroup_manager = \"cgroupfs\"/g" /etc/containers/libpod.conf

WORKDIR /root

COPY rootfs/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]