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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=coreutils          # App name
VER=8.30                # App version
PKG=file/gnu-coreutils  # Package name (without prefix)
SUMMARY="coreutils - GNU core utilities"
DESC="GNU core utilities ($VER)"

NO_PARALLEL_MAKE=1
BUILD_DEPENDS_IPS="compress/xz"
DEPENDS_IPS="library/gmp system/library"

CPPFLAGS="-I/usr/include/gmp"
PREFIX=/usr/gnu
reset_configure_opts
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --libexecdir=/usr/lib --bindir=/usr/gnu/bin"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libexecdir=/usr/lib/sparcv9 --bindir=/usr/gnu/bin/sparcv9"

link_in_usr_bin() {
    logmsg "Making links to /usr/bin"
    logcmd mkdir -p $DESTDIR/usr/bin
    for cmd in [ base64 dir dircolors install md5sum nproc pinky printenv \
	ptx readlink seq sha1sum sha224sum sha256sum sha384sum sha512sum \
	shred shuf stat stdbuf tac timeout truncate users vdir whoami 
    do
        logcmd ln $DESTDIR/usr/gnu/bin/$cmd $DESTDIR/usr/bin/$cmd
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
link_in_usr_bin
rm -f $DESTDIR/usr/sbin/core
rm -f $DESTDIR/usr/sbin/log
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
