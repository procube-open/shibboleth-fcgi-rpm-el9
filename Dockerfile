FROM almalinux/9-base
MAINTAINER "Shigeki Kitamura" <kitamura@procube.jp>
RUN groupadd -g 111 builder
RUN useradd -g builder -u 111 builder
ENV HOME /home/builder
WORKDIR ${HOME}
ENV SHIBBOLETH_VERSION "3.5.0-2.el9"
RUN dnf -y update \
    && yum -y install unzip wget sudo lsof openssh-clients telnet bind-utils tar tcpdump vim initscripts \
         gcc openssl-devel zlib-devel pcre-devel rpmdevtools make yum-utils \
         systemd-devel chrpath  httpd-devel gcc-c++ boost-devel gdb krb5-devel
RUN dnf -y --enablerepo=crb install unixODBC-devel memcached libmemcached libmemcached-devel
RUN mkdir -p /tmp/requires \
    && cd /tmp/requires/ \
    && wget --no-verbose -O /tmp/requires/lua.tar.gz https://github.com/procube-open/lua51-el9/releases/download/1.0.0/lua51-el9.tar.gz \
    && tar xvzf lua.tar.gz \
    && cd RPMS/x86_64/ \
    && rpm -ivh lua-5.*.rpm lua-devel-5.*.rpm
ADD shibboleth.repo /etc/yum.repos.d
RUN dnf -y install libxml-security-c-devel-3.0.0 libxmltooling-devel-3.3.0 libsaml-devel-3.3.0 liblog4shib-devel \
       xmltooling-schemas-3.3.0 opensaml-schemas-3.3.0
RUN dnf -y install epel-release
RUN dnf -y install fcgi-devel
RUN mkdir -p /tmp/buffer
RUN mkdir -p /tmp/rpms
RUN yumdownloader --destdir /tmp/rpms liblog4shib2 libsaml13 libxmltooling11-3.3.0 opensaml-schemas-3.3.0 \
     xmltooling-schemas-3.3.0 libxerces-c-3_3 supervisor fcgi
COPY shibboleth.spec.patch /tmp/buffer/
COPY native.logger.patch /tmp/buffer/
USER builder
RUN mkdir -p ${HOME}/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo "%_topdir %(echo ${HOME})/rpmbuild" > ${HOME}/.rpmmacros
RUN mkdir ${HOME}/srpms \
    && cd srpms \
    && wget -O ./shibboleth.src.rpm https://shibboleth-mirror.cdi.ti.ja.net/rockylinux9/src/shibboleth-${SHIBBOLETH_VERSION}.src.rpm \
    && rpm -ivh shibboleth.src.rpm
RUN cp /tmp/buffer/native.logger.patch rpmbuild/SOURCES
RUN cd rpmbuild/SPECS \
    && patch -p 1 shibboleth.spec < /tmp/buffer/shibboleth.spec.patch
COPY build.sh .
CMD ["/bin/bash","./build.sh"]
