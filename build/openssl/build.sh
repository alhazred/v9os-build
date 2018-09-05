#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=openssl
VER=1.0.2p
VERHUMAN=$VER
PKG=library/security/openssl # Package name (without prefix)
SUMMARY="$PROG - A toolkit for Secure Sockets Layer (SSL v2/v3) and Transport Layer (TLS v1) protocols and general purpose cryptographic library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library system/library/gcc-5-runtime library/zlib@1.2.8"

NO_PARALLEL_MAKE=1

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    # This will setup the internal runpath of libssl and libcrypto
    logcmd $MAKE $MAKE_JOBS SHARED_LDFLAGS="$SHARED_LDFLAGS" || \
        logerr "--- Make failed"
    logmsg "--- make test"
    logcmd $MAKE test || \
        logerr "--- make test failed"
}

configure32() {
    if [ -n "`isalist | grep sparc`" ]; then
      SSLPLAT=solaris-sparcv8-cc
    else
      SSLPLAT=solaris-x86-gcc
    fi
    logmsg "--- Configure (32-bit) $SSLPLAT"
    logcmd ./Configure $SSLPLAT --pk11-libname=/usr/lib/libpkcs11.so.1 shared threads zlib enable-ssl2 --prefix=$PREFIX ||
        logerr "Failed to run configure"
    SHARED_LDFLAGS="-shared -Wl,-z,text"
}
configure64() {
    if [ -n "`isalist | grep sparc`" ]; then
      SSLPLAT=solaris64-sparcv9-cc
    else
      SSLPLAT=solaris64-x86_64-gcc
    fi
    logmsg "--- Configure (64-bit) $SSLPLAT"
    logcmd ./Configure $SSLPLAT --pk11-libname=/usr/lib/64/libpkcs11.so.1 shared threads zlib enable-ssl2 \
        --prefix=$PREFIX ||
        logerr "Failed ot run configure"
    SHARED_LDFLAGS="-m64 -shared -Wl,-z,text"
}

make_install() {
    logmsg "--- make install"
    logcmd make INSTALL_PREFIX=$DESTDIR install ||
        logerr "Failed to make install"
}

# Move installed libs from /usr/lib to /lib and make symlinks to match upstream package
move_libs() {
    logmsg "link up certs"
    logcmd rmdir $DESTDIR/usr/ssl/certs ||
        logerr "Failed to remove /usr/ssl/certs"
    logcmd ln -s ../../etc/ssl/certs $DESTDIR/usr/ssl/certs ||
        logerr "Failed to link up /usr/ssl/certs -> /etc/ssl/certs"
    logmsg "Relocating libs from usr/lib to lib"
    logcmd mv $DESTDIR/usr/lib/64 $DESTDIR/usr/lib/sparcv9
    logcmd mkdir -p $DESTDIR/lib/sparcv9
    logcmd mv $DESTDIR/usr/lib/lib* $DESTDIR/lib/ ||
        logerr "Failed to move libs (32-bit)"
    logcmd mv $DESTDIR/usr/lib/sparcv9/lib* $DESTDIR/lib/sparcv9/ ||
        logerr "Failed to move libs (64-bit)"
    logmsg "--- Making usr/lib symlinks"
    pushd $DESTDIR/usr/lib > /dev/null
    logcmd ln -s ../../lib/libssl.so.1.0.0 libssl.so
    logcmd ln -s ../../lib/libssl.so.1.0.0 libssl.so.1.0.0
    logcmd ln -s ../../lib/libcrypto.so.1.0.0 libcrypto.so
    logcmd ln -s ../../lib/libcrypto.so.1.0.0 libcrypto.so.1.0.0
    popd > /dev/null
    pushd $DESTDIR/usr/lib/sparcv9 > /dev/null
    logcmd ln -s ../../../lib/sparcv9/libssl.so.1.0.0 libssl.so
    logcmd ln -s ../../../lib/sparcv9/libssl.so.1.0.0 libssl.so.1.0.0
    logcmd ln -s ../../../lib/sparcv9/libcrypto.so.1.0.0 libcrypto.so
    logcmd ln -s ../../../lib/sparcv9/libcrypto.so.1.0.0 libcrypto.so.1.0.0
    popd > /dev/null
}


# Turn the letter component of the version into a number for IPS versioning
ord26() {
    local ASCII=$(printf '%d' "'$1")
    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}
save_function make_package make_package_orig
make_package() {
    if [[ -n "`echo $VER | grep [a-z]`" ]]; then
        NUMVER=${VER::$((${#VER} -1))}
        ALPHAVER=${VER:$((${#VER} -1))}
        VER=${NUMVER}.$(ord26 ${ALPHAVER})
    fi

    make_package_orig
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
move_libs
make_lintlibs crypto /lib /usr/include "openssl/!(ssl*|*tls*).h"
make_lintlibs ssl /lib /usr/include "openssl/{ssl,*tls}*.h"
make_isa_stub
make_package
clean_up
