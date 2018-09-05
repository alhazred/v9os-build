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

PROG=glib
VER=2.56.2
PKG=library/glib2
SUMMARY="$PROG - GNOME GLib utility library"
DESC="$SUMMARY"

DEPENDS_IPS="
    runtime/python-27
    runtime/perl
"
export CFLAGS="$CFLAGS -std=gnu89"

CONFIGURE_OPTS="--disable-fam --disable-dtrace --with-threads=posix --disable-dependency-tracking"

save_function configure32 configure32_orig
save_function configure64 configure64_orig
configure32() {
    LIBFFI_CFLAGS=-I/usr/lib/libffi-$FFIVERS/include
    export LIBFFI_CFLAGS
    LIBFFI_LIBS=-lffi
    export LIBFFI_LIBS
    configure32_orig

    logcmd perl -pi -e 's#(\$CC.*\$compiler_flags)#$1 -nostdlib -lc#g;' libtool ||
        logerr "libtool patch failed"
    # one file here requires c99 compilation and most others prohibit it
    # it is a test, so no runtime issues will be present
    pushd glib/tests > /dev/null
    logmsg " one off strfuncs.o c99 compile"
    logcmd make CFLAGS="-std=c99" strfuncs.o
    popd > /dev/null
}
configure64() {
    LIBFFI_CFLAGS=-I/usr/lib/sparcv9/libffi-$FFIVERS/include
    export LIBFFI_CFLAGS
    LIBFFI_LIBS=-lffi
    export LIBFFI_LIBS
    configure64_orig

    logcmd perl -pi -e 's#(\$CC.*\$compiler_flags)#$1 -nostdlib -lc#g;' libtool ||
        logerr "libtool patch failed"
    # one file here requires c99 compilation and most others prohibit it
    # it is a test, so no runtime issues will be present
    pushd glib/tests > /dev/null
    logmsg " one off strfuncs.o c99 compile"
    logcmd make CFLAGS="-m64 -std=c99" strfuncs.o
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up
