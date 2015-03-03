#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
TEAL=$(tput setaf 6)
NORMAL=$(tput sgr0)
BOLD=$(tput bold)
MODEST=${YELLOW}${BOLD}

if [ ! -f external/umundo/sdl2-cross-changes.md ] ; then
    echo "${RED}Error:${NORMAL} execute script from base directory"
    exit 1
fi

cd external/umundo/

function get_source {
    echo "
${GREEN}[ Preparing ${BOLD}$1${NORMAL}${GREEN} ]${NORMAL}"
    if [ -d "$1" ] ; then
        echo " - Directory $1 already exists. ${YELLOW}Skipping.${NORMAL}"
    else
        echo " - Downloading $1..."
        eval "$2"
    fi
}

function say_done {
    echo "${GREEN} - done${NORMAL}"
}


function unpack {
    if [ -e "$1" ] ; then
        echo "${TEAL} - unpacking"
        tar xf "$1" && rm "$1"
    fi
}


# $1 type (scons, android)
# $2 source
# $3 destination
function add_build_script {
    if [ -e "$3" ] ; then
        echo " - Found $1 build script ${BOLD}$3${NORMAL} ${YELLOW}Skipping${NORMAL}"
    else
        echo "${TEAL} - adding $1 build script ${BOLD}$3${NORMAL}"
        if [ ! -d $(dirname "$3") ] ; then mkdir -p $(dirname "$3") ; fi
        nsub=$(($(grep -o '/' <<< "$3" | wc -l) + 2))
        subdepth=$(yes "../" | head -n $nsub | xargs)
        subdepth=${subdepth// /}
        ln -s ${subdepth}utils/build_scripts/umundo/"$2" "$3"
    fi
}

# fastlz
get_source fastlz \
"svn checkout http://fastlz.googlecode.com/svn/trunk/ fastlz"
say_done


# zeromq
get_source zeromq-4.1.0 \
"wget http://download.zeromq.org/zeromq-4.1.0-rc1.tar.gz"
unpack "zeromq-4.1.0-rc1.tar.gz"
add_build_script "SCons" SConscript_zeromq "zeromq-4.1.0/SConscript"
add_build_script "header file" zmq_platform_linux.hpp \
    "zeromq-4.1.0/include_linux/platform.hpp"
say_done


# re
get_source re-0.4.7 \
"wget http://creytiv.com/pub/re-0.4.7.tar.gz"
unpack "re-0.4.7.tar.gz"
add_build_script "SCons" SConscript_re "re-0.4.7/SConscript"
say_done


# mDNSResponder
mdir=mDNSResponder-333.10
get_source ${mdir} \
"wget http://www.opensource.apple.com/tarballs/mDNSResponder/mDNSResponder-333.10.tar.gz"
unpack "mDNSResponder-333.10.tar.gz"
if [ -e ${mdir}/.patched ] ; then
    echo " - Already patched. ${YELLOW}Skipping${NORMAL}"
else
    echo "${TEAL} - patching ${NORMAL}"
    patch -p0 < ../../utils/patches/mDNSResponder-333.10.umundo.patch
    patch -p1 < ../../utils/patches/mDNSResponder-333.10.reuseport.patch
    touch ${mdir}/.patched
fi
add_build_script "SCons" SConscript_mDNSResponder "${mdir}/SConscript"
add_build_script "header file" umundo_linux_config.h \
    "src/include_linux/umundo/config.h"
say_done


