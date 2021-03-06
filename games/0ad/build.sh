#!/bin/bash

set -e

source ../../lib/util.sh

version="alpha20"
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="${root_dir}/0ad-src"
bin_dir="${root_dir}/0ad"

InstallBuildDependencies() {
    install_deps build-essential libboost-dev libboost-filesystem-dev   \
    libcurl4-gnutls-dev libenet-dev libgloox-dev libicu-dev    \
    libminiupnpc-dev libnspr4-dev libnvtt-dev libogg-dev libopenal-dev   \
    libpng-dev libsdl2-dev libvorbis-dev libwxgtk3.0-dev libxcursor-dev      \
    libxml2-dev subversion zlib1g-dev subversion
}

GetSources() {
    cd $root_dir
    svn co http://svn.wildfiregames.com/public/ps/trunk/ 0ad-src

    # To build a specific version use revision numbers available here:
    # http://trac.wildfiregames.com/wiki/Changelogs

    # For Alpha 20:
    # svn co -r 17965 http://svn.wildfiregames.com/public/ps/trunk/
}

BuildProject() {
    cd ${source_dir}/build/workspaces
    ./update-workspaces.sh -j3
    cd gcc
    make -j3
}

PackageProject() {
    rm -rf $bin_dir
    cd $source_dir
    cp -a binaries $bin_dir
    cd $bin_dir
    rm -f system/*.dll
    rm -f system/*.pdb
    rm -f system/*.exe
    rm -f system/*.sys
    rm -f system/*.bat
    rm -f system/test
    strip system/pyrogenesis
    strip system/ActorEditor
    strip system/*.so
    cd $root_dir
    tar czf 0ad-${version}-${arch}.tar.gz 0ad
}

Cleanup() {
    rm -rf $source_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
fi
