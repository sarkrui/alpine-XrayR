#!/usr/bin/env bash

set -euxo pipefail

# Identify architecture
case "$(arch -s)" in
    'i386' | 'i686')
        MACHINE='32'
        ;;
    'amd64' | 'x86_64')
        MACHINE='64'
        ;;
    'armv5tel')
        MACHINE='arm32-v5'
        ;;
    'armv6l')
        MACHINE='arm32-v6'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
    'armv7' | 'armv7l')
        MACHINE='arm32-v7a'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
    'armv8' | 'aarch64')
        MACHINE='arm64-v8a'
        ;;
    'mips')
        MACHINE='mips32'
        ;;
    'mipsle')
        MACHINE='mips32le'
        ;;
    'mips64')
        MACHINE='mips64'
        ;;
    'mips64le')
        MACHINE='mips64le'
        ;;
    'ppc64')
        MACHINE='ppc64'
        ;;
    'ppc64le')
        MACHINE='ppc64le'
        ;;
    'riscv64')
        MACHINE='riscv64'
        ;;
    's390x')
        MACHINE='s390x'
        ;;
    *)
        echo "error: The architecture is not supported."
        exit 1
        ;;
esac

TMP_DIRECTORY="$(mktemp -d)/"
ZIP_FILE="${TMP_DIRECTORY}XrayR-linux-$MACHINE.zip"
DOWNLOAD_LINK="https://github.com/XrayR-project/XrayR/releases/latest/download/XrayR-linux-$MACHINE.zip"

install_software() {
    if [[ -n "$(command -v curl)" ]]; then
        return
    fi
    if [[ -n "$(command -v unzip)" ]]; then
        return
    fi
    if [ "$(command -v apk)" ]; then
        apk add curl unzip tzdata
        echo "\n" | setup-ntp 
    else
        echo "error: The script does not support the package manager in this operating system."
        exit 1
    fi
}

download_xrayr() {
    curl -L -H 'Cache-Control: no-cache' -o "$ZIP_FILE" "$DOWNLOAD_LINK" -#
    if [ "$?" -ne '0' ]; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 1
    fi
}

decompression() {
    unzip -q "$ZIP_FILE" -d "$TMP_DIRECTORY"
}

is_it_running() {
    XRAYR_RUNNING='0'
    if [ -n "$(pgrep XrayR)" ]; then
        rc-service XrayR stop
        rc-update del XrayR
        XRAYR_RUNNING='1'
    fi
}

install_xrayr() {
    install -m 755 "${TMP_DIRECTORY}XrayR" "/usr/local/XrayR/XrayR"
    install -d /usr/local/XrayR/
    install -m 755 "${TMP_DIRECTORY}geoip.dat" "/etc/XrayR/geoip.dat"
    install -m 755 "${TMP_DIRECTORY}geosite.dat" "/etc/XrayR/geosite.dat"
}

install_confdir() {
    CONFDIR='0'
    if [ ! -d '/usr/local/etc/XrayR/' ]; then
        install -d /usr/local/etc/XrayR/
        for BASE in 00_log 01_api 02_dns 03_routing 04_policy 05_inbounds 06_outbounds 07_transport 08_stats 09_reverse; do
            echo '{}' > "/usr/local/etc/XrayR/$BASE.json"
        done
        CONFDIR='1'
    fi
}

install_startup_service_file() {
    OPENRC='0'
    if [ ! -f '/etc/init.d/XrayR' ]; then
        mkdir "${TMP_DIRECTORY}init.d/"
        curl -o "${TMP_DIRECTORY}init.d/XrayR" https://raw.githubusercontent.com/sarkrui/alpine-XrayR/main/init.d/XrayR -s
        rc-update add XrayR
        rc-service XrayR start
        if [ "$?" -ne '0' ]; then
            echo 'error: Failed to start service file download! Please check your network or try again.'
            exit 1
        fi
        install -m 755 "${TMP_DIRECTORY}init.d/XrayR" /etc/init.d/XrayR
        OPENRC='1'
    fi
}

information() {
    echo 'installed: /usr/local/XrayR/XrayR'
    echo 'installed: /etc/XrayR/geoip.dat'
    echo 'installed: /etc/XrayR/geosite.dat'
    echo 'installed: /etc/XrayR/config.yml'
    if [ "$CONFDIR" -eq '1' ]; then
        echo 'installed: /usr/local/etc/XrayR/00_log.json'
        echo 'installed: /usr/local/etc/XrayR/01_api.json'
        echo 'installed: /usr/local/etc/XrayR/02_dns.json'
        echo 'installed: /usr/local/etc/XrayR/03_routing.json'
        echo 'installed: /usr/local/etc/XrayR/04_policy.json'
        echo 'installed: /usr/local/etc/XrayR/05_inbounds.json'
        echo 'installed: /usr/local/etc/XrayR/06_outbounds.json'
        echo 'installed: /usr/local/etc/XrayR/07_transport.json'
        echo 'installed: /usr/local/etc/XrayR/08_stats.json'
        echo 'installed: /usr/local/etc/XrayR/09_reverse.json'
    fi
    if [ "$LOG" -eq '1' ]; then
        echo 'installed: /var/log/XrayR/'
    fi
    if [ "$OPENRC" -eq '1' ]; then
        echo 'installed: /etc/init.d/XrayR'
    fi
    rm -r "$TMP_DIRECTORY"
    echo "removed: $TMP_DIRECTORY"
    echo "You may need to execute a command to remove dependent software: apk del curl unzip"
    if [ "$XRAY_RUNNING" -eq '1' ]; then
        rc-service XrayR start
    else
        echo 'Please execute the command: rc-update add XrayR; rc-service XrayR start'
    fi
    echo "info: XrayR is installed."
}

main() {
    install_software
    download_xrayr
    decompression
    is_it_running
    install_xrayr
    install_confdir
    install_log
    install_startup_service_file
    information
}

main
