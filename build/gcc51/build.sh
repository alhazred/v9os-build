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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=gcc
VER=5.1.0
VERHUMAN=$VER
PKG=developer/gcc51
SUMMARY="gcc ${VER}"
DESC="$SUMMARY"

export LD_LIBRARY_PATH=/opt/gcc-${VER}/lib
PATH=/usr/perl5/5.16.1/bin:$PATH
export PATH

DEPENDS_IPS="developer/gcc51/libgmp-gcc51 developer/gcc51/libmpfr-gcc51 developer/gcc51/libmpc-gcc51 developer/library/lint developer/linker system/library/gcc-5-runtime"

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-${VER}
reset_configure_opts
CC=gcc

LD_FOR_TARGET=/usr/bin/ld
export LD_FOR_TARGET
LD_FOR_HOST=/usr/bin/ld
export LD_FOR_HOST
LD=/bin/ld
export LD

CONFIGURE_OPTS_32="--prefix=/opt/gcc-${VER}"
CONFIGURE_OPTS="--host sparc-sun-solaris2.11 --build sparc-sun-solaris2.11 --target sparc-sun-solaris2.11 \
	--with-boot-ldflags=-R/opt/gcc-${VER}/lib \
	--with-gmp=/opt/gcc-${VER} --with-mpfr=/opt/gcc-${VER} --with-mpc=/opt/gcc-${VER} \
	--enable-languages=c,c++,objc --without-gnu-ld --with-ld=/usr/bin/ld \
        --disable-libgomp --disable-libquadmath-support --disable-libquadmath \
	--with-as=/usr/ccs/bin/as --without-gnu-as --with-build-time-tools=/usr/gnu/sparc-sun-solaris2.11/bin"
LDFLAGS32="-R/opt/gcc-${VER}/lib"
export LD_OPTIONS="-zignore -zcombreloc -i"

init
download_source $PROG/releases/$PROG-$VER $PROG $VER
patch_source
prep_build
build


make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install || \
        logerr "--- Make install failed"
}
pushd /tmp/build_root/gcc-5.1.0 
make_install
popd >/dev/null
make_package gcc.mog
clean_up
