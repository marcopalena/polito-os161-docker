#!/usr/bin/env bash

set -e

BINUTILS_161="binutils-2.24+os161-2.1"
GCC_161="gcc-4.8.3+os161-2.1"
GDB_161="gdb-7.8+os161-2.1"
SYS_161="sys161-2.0.8"

INSTALL_DIR="/usr/local/os161"
BUILD_DIR="/tmp/os161"

export CC="gcc"
export CFLAGS=

build_binutils() {
    echo '*** Building binutils ***'
    if ! (
        set -e
        cd "${BUILD_DIR}/${BINUTILS_161}"
        find . -name '*.info' | xargs touch
        touch "intl/plural.c"
        ./configure \
            --nfp \
            --disable-werror \
            --target=mips-harvard-os161 \
            --prefix="${INSTALL_DIR}" 2>&1
        make -j"$(nproc)" 2>&1
        make install 2>&1
        cd .. && rm -rf "${BUILD_DIR}/${BINUTILS_161}"
    ) > /var/log/binutils.log; then
        tail /var/log/binutils.log
        exit 1
    fi
}

build_gcc() {
    echo '*** Building gcc ***'
    if ! (
        set -e
        find "${BUILD_DIR}/${GCC_161}" -name '*.info' | xargs touch
        touch "${BUILD_DIR}/${GCC_161}/intl/plural.c"
        mkdir -p "${BUILD_DIR}/buildgcc"
        cd "${BUILD_DIR}/buildgcc"
        "${BUILD_DIR}/${GCC_161}/configure" \
            --enable-languages=c,lto \
            --nfp \
            --disable-shared \
            --disable-threads \
            --disable-libmudflap \
            --disable-libssp \
            --disable-libstdcxx \
            --disable-nls \
            --target=mips-harvard-os161 \
            --prefix="${INSTALL_DIR}/" 2>&1
        make -j"$(nproc)" 2>&1
        make install 2>&1
        cd .. && rm -rf "${BUILD_DIR}/buildgcc" && rm -rf "${BUILD_DIR}/${GCC_161}"
    ) > /var/log/gcc.log; then
        tail /var/log/gcc.log && exit 1
    fi
}

build_gdb() {
    echo '*** Building gdb ***'
    if ! (
        set -e
        cd "${BUILD_DIR}/${GDB_161}"
        patch --strip=1 < "${BUILD_DIR}/110-no_extern_inline.patch"
        find . -name '*.info' | xargs touch
        touch "intl/plural.c"
        ./configure \
            --disable-werror \
            --target=mips-harvard-os161 \
            --prefix="${INSTALL_DIR}" 2>&1
        make -j"$(nproc)" 2>&1
        make install 2>&1
        rm -rf "${BUILD_DIR}/${GDB_161}"
    ) > /var/log/gdb.log; then
        tail /var/log/gdb.log && exit 1
    fi
}

build_sys161() {
    echo '*** Building System/161 ***'
    if ! (
        set -e
        cd "${BUILD_DIR}/${SYS_161}"
        ./configure \
            --prefix="${INSTALL_DIR}" mipseb
        make -j"$(nproc)" 2>&1
        make install 2>&1
        rm -rf "${BUILD_DIR}/${SYS_161}"
    ) > /var/log/sys161.log; then
        tail /var/log/sys161.log && exit 1
    fi
}

link_files() {
    echo '*** Creating symbolic links ***'
    (
        set -e
        cd "${INSTALL_DIR}/bin"
        for file in mips-*; do 
            ln -s --relative "${file}" "/usr/local/bin/${file:13}";
            ln -s --relative "${file}" "/usr/local/bin/${file}";
            printf "\t%s\n" "/usr/local/bin/${file:13}"
        done
        for file in disk161 hub161 stat161 sys161 trace161; do 
            ln -s --relative "${file}" "/usr/local/bin/${file}";
            printf "\t%s\n" "/usr/local/bin/${file}"
        done
        hash -r
    )
}

help() {
    printf "%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n" "USAGE: $0" \
        "[-u BINUTILS_161_VERSION ]" \
        "[-c GCC_161_VERSION ]" \
        "[-d GDB_161_VERSION ]" \
        "[-s SYS161_VERSION ]" \
        "[-i INSTALL_DIR ]" \
        "[-b BUILD_DIR ]"
}

main() {
    build_binutils
    build_gcc
    build_gdb
    build_sys161
    # link_files
}

options=':u:c:d:s:i:b:h'
while getopts $options option
do
    case $option in
        u  ) BINUTILS_161=${OPTARG};;
        c  ) GCC_161=${OPTARG};;
        d  ) GDB_161=${OPTARG};;
        s  ) SYS_161=${OPTARG};;
        i  ) INSTALL_DIR=${OPTARG};;
        b  ) BUILD_DIR=${OPTARG};;
        h  ) help;;
        \? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
        :  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
        *  ) echo "Unimplemented option: -${OPTARG}" >&2; exit 1;;
    esac
done

shift $((OPTIND - 1))

echo "BINUTILS_161=${BINUTILS_161}"
echo "GCC_161=${GCC_161}"
echo "GDB_161=${GDB_161}"
echo "SYS_161=${SYS_161}"
echo "INSTALL_DIR=${INSTALL_DIR}"
echo "BUILD_DIR=${BUILD_DIR}"

main