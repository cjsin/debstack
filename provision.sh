#!/bin/bash
#set -e

DEVUSER=""
SOURCES=""
CLEAN=0
export DEBIAN_FRONTEND="noninteractive"

function INSTALL()
{
    apt-get install -y --no-install-recommends "${@}" || echo "Nothing to install"
}

function prep()
{
    if [[ -d "/vagrant" ]]
    then
        echo "Running in vagrant"
        export DEVUSER="vagrant"
        export SOURCES="/vagrant"
        export CLEAN=0
        sed -r -i \
           -e '/PasswordAuthentication no/ s/no/yes/' \
           -e 's/^(|#)(PermitRootLogin)[[:space:]]*(.*)/\2 yes/' \
           /etc/ssh/sshd_config 
        systemctl restart sshd
    elif [[ ! -d "/lib/modules" ]]
    then
        echo "Running in docker"
        hostname "dockerhost"
        export DEVUSER="dev"
        export SOURCES="/docker"
        # For now, until the build is stable, leave the package data for faster builds
        export CLEAN=0
        create_user "${DEVUSER}"
    else
        echo "Could not determine if running in docker or vagrant" 1>&2
        exit 1
    fi

    export WORK="/home/${DEVUSER}/work"
    [[ -e "${WORK}" ]] || ln -s "${SOURCES}" "${WORK}"
    chown -R "${DEVUSER}.${DEVUSER}" "${WORK}"

    cd "${WORK}"
}

function create_user()
{
    groupadd -g 1000 "${1}" \
      && useradd -u 1000 -g 1000 -d "/home/${1}" "${1}"
}

function systemd_fix()
{
    if [[ ! -f "/bin/systemctl" ]]
    then
        # Need to either install systemd or else apply this patch
        # apt-get update && INSTALL systemd
        sed -i -r -e '/fakechroot_chroot_paths#/ i\    fakechroot_chroot_paths+=":${fakechroot_chroot_newroot}/lib/systemd";' /usr/sbin/chroot.fakechroot
    else
        return 0
    fi
}

function cleanup()
{
    if (( CLEANUP ))
    then
        apt-get autoremove -y \
            && apt-get remove --purge -y \
            && apt-get clean \
            && cd /var/lib/apt/lists \
            && rm -f deb.* security.* \
            && rm -f /var/cache/apt/*.bin
    else
        return 0
    fi
}

function install_tools()
{
    ( apt-get update && INSTALL debirf mtools genisoimage make) || echo "Nothing done"
}

function prepare_for_debirf()
{
    touch /root/.dpkg.cfg \
        && chmod a+r /root/.dpkg.cfg \
        && chmod a+rx /root \
        && systemd_fix
}

function main()
{
    prep \
        && install_tools \
        && cleanup \
        && prepare_for_debirf
}

main
