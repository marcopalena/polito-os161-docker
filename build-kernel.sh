#!/usr/bin/env bash

set -e

CONF="DUMBVM"
SOURCE_DIR="/home/os161user/os161/src"
INSTALL_DIR="/home/os161user/os161/root"

build_userland() {
    echo '*** Building the OS/161 userland ***'
    if ! (
        set -e
        cd "${SOURCE_DIR}"
        ./configure --ostree="${INSTALL_DIR}"
        bmake -j"$(nproc)"
        bmake install
    ) > /tmp/os161_userland.log; then
        tail /tmp/os161_userland.log
        exit 1
    fi
}

configure_kernel() {
    echo '*** Configuring the OS/161 kernel ***'
    if ! (
        set -e
        cd "${SOURCE_DIR}/kern/conf"
        ./config "${CONF}"
    ) > /tmp/os161_conf.log; then
        tail /tmp/os161_conf.log
        exit 1
    fi
}

compile_kernel() {
    echo '*** Compiling the OS/161 kernel ***'
    if ! (
        set -e
        cd "${SOURCE_DIR}/kern/compile/${CONF}/"
        bmake depend
        bmake
        bmake install
    ) > /tmp/os161_compile.log; then
        tail /tmp/os161_compile.log
        exit 1
    fi
}

create_disk_images() {
    echo '*** Create disk images ***'
    if ! (
        set -e
        cd "${INSTALL_DIR}"
        if [ -f "LHD0.img" ]; then
            rm LHD0.img
        fi
        if [ -f "LHD1.img" ]; then
            rm LHD1.img
        fi
        disk161 create LHD0.img 5M
        disk161 create LHD1.img 5M
    ) > /tmp/disks.log; then
        tail /tmp/disks.log
        exit 1
    fi
}

help() {
    printf "%s\n\t%s\n\t%s\n\t%s\n\t%s\n" "USAGE: $0" \
        "[-c CONF ]" \
        "[-s SOURCE_DIR ]" \
        "[-i INSTALL_DIR ]"
}

main() {
    build_userland
    configure_kernel
    compile_kernel
    create_disk_images
}

options=':c:s:i:h'
while getopts $options option
do
    case $option in
        c  ) CONF=${OPTARG};;
        s  ) SOURCE_DIR=${OPTARG};;
        i  ) INSTALL_DIR=${OPTARG};;
        h  ) help;;
        \? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
        :  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
        *  ) echo "Unimplemented option: -${OPTARG}" >&2; exit 1;;
    esac
done

shift $((OPTIND - 1))

echo "CONF=${CONF}"
echo "SOURCE_DIR=${SOURCE_DIR}"
echo "INSTALL_DIR=${INSTALL_DIR}"

main