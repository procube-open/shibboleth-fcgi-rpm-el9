#!/bin/bash
mkdir -p ./rpmbuild/{BUILD/x86_64,RPMS,SOURCES,SPECS,SRPMS}

rpmbuild -bb rpmbuild/SPECS/shibboleth.spec --with fastcgi --with memcached --without doxygen
cp /tmp/rpms/* rpmbuild/RPMS/x86_64
