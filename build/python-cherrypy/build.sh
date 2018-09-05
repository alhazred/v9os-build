#!/usr/bin/bash
#
# {{{ CDDL HEADER START
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
# CDDL HEADER END }}}
#
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../../lib/functions.sh

PKG=library/python-2/cherrypy-27
PROG=CherryPy
VER=17.3.0
SUMMARY="cherrypy - A Minimalist Python Web Framework"
DESC="$SUMMARY"

. $SRCDIR/../common.sh

RUN_DEPENDS_IPS+="
    library/python-$PYMVER/tempora-$SPYVER
    library/python-$PYMVER/six-$SPYVER
    library/python-$PYMVER/portend-$SPYVER
    library/python-$PYMVER/cheroot-$SPYVER
    library/python-$PYMVER/jaraco.classes-$SPYVER
    library/python-$PYMVER/functools_lru_cache-$SPYVER
    library/python-$PYMVER/zc.lockfile-$SPYVER
    library/python-$PYMVER/contextlib2-$SPYVER
"

init
download_source pymodules/${PROG,,} $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
