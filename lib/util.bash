#!/bin/bash -e

########################
# FILE LOCAL UTILITIES #
########################

function appendToFileIfNotFound()
{
    local file="${1}"
    local pattern="${2}"
    local string="${3}"
    local patternAsRegex="${4}"
    local stringAsRegex="${5}"

    if [[ -f "${file}" ]]
    then
        local grepOption='--fixed-strings --only-matching'

        if [[ "${patternAsRegex}" = 'true' ]]
        then
            grepOption='--extended-regexp --only-matching'
        fi

        local found="$(grep ${grepOption} "${pattern}" "${file}")"

        if [[ "$(isEmptyString "${found}")" = 'true' ]]
        then
            if [[ "${stringAsRegex}" = 'true' ]]
            then
                echo -e "${string}" >> "${file}"
            else
                echo >> "${file}"
                echo "${string}" >> "${file}"
            fi
        fi
    else
        fatal "FATAL: file '${file}' not found!"
    fi
}

function createFileFromTemplate()
{
    local sourceFile="${1}"
    local destinationFile="${2}"
    local data=("${@:3}")

    if [[ -f "${sourceFile}" ]]
    then
        local content="$(cat "${sourceFile}")"
        local i=0

        for ((i = 0; i < ${#data[@]}; i = i + 2))
        do
            local oldValue="$(escapeSearchPattern "${data[${i}]}")"
            local newValue="$(escapeSearchPattern "${data[${i} + 1]}")"

            content="$(echo "${content}" | sed "s@${oldValue}@${newValue}@g")"
        done

        echo "${content}" > "${destinationFile}"
    else
        fatal "FATAL: file '${sourceFile}' not found!"
    fi
}

function getFileExtension()
{
    local fullFileName="$(basename "${1}")"

    echo "${fullFileName##*.}"
}

function getFileName()
{
    local fullFileName="$(basename "${1}")"

    echo "${fullFileName%.*}"
}

function symlinkLocalBin()
{
    local sourceBinFolder="${1}"

    local file=''

    for file in $(find "${sourceBinFolder}" -maxdepth 1 -xtype f -perm -u+x)
    do
        local localBinFile="/usr/local/bin/$(basename "${file}")"

        rm -f "${localBinFile}"
        ln --symbolic "${file}" "${localBinFile}"
    done
}

#########################
# FILE REMOTE UTILITIES #
#########################

function existURL()
{
    local url="${1}"

    # Install Curl

    installCURLCommand > '/dev/null'

    # Check URL

    if ( curl --output '/dev/null' --silent --head --fail "${url}" )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function getRemoteFileContent()
{
    local url="${1}"

    # Install Curl

    installCURLCommand

    # Get Content

    curl --silent --request 'GET' "${url}"
}

function unzipRemoteFile()
{
    local downloadURL="${1}"
    local installFolder="${2}"
    local extension="${3}"

    # Install Curl

    installCURLCommand

    # Find Extension

    if [[ "$(isEmptyString "${extension}")" = 'true' ]]
    then
        extension="$(getFileExtension "${downloadURL}")"
        local exExtension="$(echo "${downloadURL}" | rev | cut -d '.' -f 1-2 | rev)"
    fi

    # Unzip

    if [[ "$(echo "${extension}" | grep --ignore-case '^tgz$')" != '' ||
          "$(echo "${extension}" | grep --ignore-case '^tar\.gz$')" != '' ||
          "$(echo "${exExtension}" | grep --ignore-case '^tar\.gz$')" != '' ]]
    then
        debug "\nDownloading '${downloadURL}'"
        curl --location "${downloadURL}" | tar --directory "${installFolder}" --extract --gzip --strip 1
        echo
    elif [[ "$(echo "${extension}" | grep --ignore-case '^zip$')" != '' ]]
    then
        # Install Unzip

        installUnzipCommand

        # Unzip

        if [[ "$(existCommand 'unzip')" = 'true' ]]
        then
            local zipFile="${installFolder}/$(basename "${downloadURL}")"

            debug "\nDownloading '${downloadURL}'"
            curl --location "${downloadURL}" --output "${zipFile}"
            unzip -q "${zipFile}" -d "${installFolder}"
            rm -f "${zipFile}"
            echo
        else
            fatal "FATAL: install 'unzip' command failed!"
        fi
    else
        fatal "FATAL: file extension '${extension}' is not yet supported to unzip!"
    fi
}

#####################
# PACKAGE UTILITIES #
#####################

function getLastAptGetUpdate()
{
    local aptDate="$(stat --format %Y '/var/cache/apt')"
    local nowDate="$(date +'%s')"

    echo $((${nowDate} - ${aptDate}))
}

function installAptGetPackage()
{
    local package="${1}"

    if [[ "$(isAptGetPackageInstall "${package}")" = 'true' ]]
    then
        debug "\nApt-Get Package '${package}' has already been installed"
    else
        echo -e "\033[1;35m\nInstalling Apt-Get package '${package}'\033[0m"
        apt-get install --assume-yes "${package}"
    fi
}

function installAptGetPackages()
{
    runAptGetUpdate

    local package=''

    for package in ${@}
    do
        installAptGetPackage "${package}"
    done
}

function installCleanUp()
{
    apt-get clean
}

function installCommands()
{
    local data=("${@}")

    runAptGetUpdate

    local i=0

    for ((i = 0; i < ${#data[@]}; i = i + 2))
    do
        local command="${data[${i}]}"
        local package="${data[${i} + 1]}"

        if [[ "$(isEmptyString "${command}")" = 'true' ]]
        then
            fatal "\nFATAL: undefined command!"
        fi

        if [[ "$(isEmptyString "${package}")" = 'true' ]]
        then
            fatal "\nFATAL: undefined package!"
        fi

        if [[ "$(existCommand "${command}")" = 'false' ]]
        then
            installAptGetPackages "${package}"
        fi
    done
}

function installCURLCommand()
{
    local commandPackage=('curl' 'curl')

    installCommands "${commandPackage[@]}"
}

function installExpectCommand()
{
    local commandPackage=('expect' 'expect')

    installCommands "${commandPackage[@]}"
}

function installPIPCommand()
{
    local commandPackage=('pip' 'python-pip')

    installCommands "${commandPackage[@]}"
}

function installPIPPackage()
{
    local package="${1}"

    if [[ "$(isPIPPackageInstall "${package}")" = 'true' ]]
    then
        debug "PIP Package '${package}' found!"
    else
        echo -e "\033[1;35m\nInstalling PIP package '${package}'\033[0m"
        pip install "${package}"
    fi
}

function installUnzipCommand()
{
    local commandPackage=('unzip' 'unzip')

    installCommands "${commandPackage[@]}"
}

function isAptGetPackageInstall()
{
    local package="${1}"

    local found="$(dpkg --get-selections | grep --extended-regexp --only-matching "^${package}(:amd64)*\s+install$")"

    if [[ "$(isEmptyString "${found}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function isPIPPackageInstall()
{
    local package="${1}"

    # Install PIP

    installPIPCommand > '/dev/null'

    # Check Command

    if [[ "$(existCommand 'pip')" = 'true' ]]
    then
        local found="$(pip list | grep --extended-regexp --only-matching "^${package}\s+\(.*\)$")"

        if [[ "$(isEmptyString "${found}")" = 'true' ]]
        then
            echo 'false'
        else
            echo 'true'
        fi
    else
        fatal "FATAL: install 'python-pip' command failed!"
    fi
}

function runAptGetUpdate()
{
    local updateInterval="${1}"

    local lastAptGetUpdate="$(getLastAptGetUpdate)"

    if [[ "$(isEmptyString "${updateInterval}")" = 'true' ]]
    then
        updateInterval="$((24 * 60 * 60))"    # 24 hours
    fi

    if [[ "${lastAptGetUpdate}" -gt "${updateInterval}" ]]
    then
        apt-get update --fix-missing
    else
        local lastUpdate="$(date --universal --date @"${lastAptGetUpdate}" +'%-Hh %-Mm %-Ss')"

        info "\nSkip apt-get update because its last run was '${lastUpdate}' ago"
    fi
}

function runAptGetUpgrade()
{
    runAptGetUpdate

    apt-get dist-upgrade --assume-yes --fix-missing
    apt-get upgrade --assume-yes --fix-missing
    apt-get autoremove --assume-yes
}

function upgradePIPPackage()
{
    local package="${1}"

    if [[ "$(isPIPPackageInstall "${package}")" = 'true' ]]
    then
        echo -e "\033[1;35mUpgrading PIP package '${package}'\033[0m"
        pip install --upgrade "${package}"
    else
        debug "PIP Package '${package}' not found!"
    fi
}

####################
# STRING UTILITIES #
####################

function debug()
{
    echo -e "\033[1;34m${1}\033[0m"
}

function error()
{
    echo -e "\033[1;31m${1}\033[0m" 1>&2
}

function escapeSearchPattern()
{
    echo "$(echo "${1}" | sed "s@\[@\\\\[@g" | sed "s@\*@\\\\*@g" | sed "s@\%@\\\\%@g")"
}

function fatal()
{
    error "${1}"
    exit 1
}

function formatPath()
{
    local string="${1}"

    while [[ "$(echo "${string}" | grep --fixed-strings '//')" != '' ]]
    do
        string="$(echo "${string}" | sed -e 's/\/\/*/\//g')"
    done

    echo "${string}" | sed -e 's/\/$//g'
}

function header()
{
    echo -e "\n\033[1;33m>>>>>>>>>> \033[1;4;35m${1}\033[0m \033[1;33m<<<<<<<<<<\033[0m\n"
}

function info()
{
    echo -e "\033[1;36m${1}\033[0m"
}

function isEmptyString()
{
    if [[ "$(trimString ${1})" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function trimString()
{
    echo "${1}" | sed -e 's/^ *//g' -e 's/ *$//g'
}

function warn()
{
    echo -e "\033[1;33m${1}\033[0m" 1>&2
}

####################
# SYSTEM UTILITIES #
####################

function addSystemUser()
{
    local uid="${1}"
    local gid="${2}"

    if [[ "${uid}" = "${gid}" ]]
    then
        adduser --system --no-create-home --disabled-login --disabled-password --group "${gid}" >> /dev/null 2>&1
    else
        addgroup "${gid}" >> /dev/null 2>&1
        adduser --system --no-create-home --disabled-login --disabled-password --ingroup "${gid}" "${uid}" >> /dev/null 2>&1
    fi
}

function checkRequirePort()
{
    local ports="${@}"

    local headerRegex='^COMMAND\s\+PID\s\+USER\s\+FD\s\+TYPE\s\+DEVICE\s\+SIZE\/OFF\s\+NODE\s\+NAME$'
    local status="$(lsof -i -n -P | grep "\( (LISTEN)$\)\|\(${headerRegex}\)")"
    local open=''
    local port=''

    for port in ${ports}
    do
        local found="$(echo "${status}" | grep ":${port} (LISTEN)$")"

        if [[ "$(isEmptyString "${found}")" = 'false' ]]
        then
            open="${open}\n${found}"
        fi
    done

    if [[ "$(isEmptyString "${open}")" = 'false' ]]
    then
        echo -e  "\033[1;31mFollowing ports are still opened. Make sure you uninstall or stop them before a new installation!\033[0m"
        echo -en "\033[1;34m\n$(echo "${status}" | grep "${headerRegex}")\033[0m"
        echo -e  "\033[1;36m${open}\033[0m\n"
        exit 1
    fi
}

function checkRequireRootUser()
{
    checkRequireUser 'root'
}

function checkRequireSystem()
{
    if [[ "$(isUbuntuDistributor)" = 'false' ]]
    then
        fatal "\nFATAL: this program only supports 'Ubuntu' operating system!"
    fi

    if [[ "$(is64BitSystem)" = 'false' ]]
    then
        fatal "\nFATAL: this program only supports 'x86_64' operating system!"
    fi
}

function checkRequireUser()
{
    local user="${1}"

    if [[ "$(whoami)" != "${user}" ]]
    then
        fatal "\nFATAL: please run this program as '${user}' user!"
    fi
}

function displayOpenPorts()
{
    header 'LIST OPEN PORTS'

    sleep 5
    lsof -i -n -P | grep ' (LISTEN)$' | sort
}

function existCommand()
{
    local command="${1}"

    if [[ "$(which "${command}")" = '' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function existGroup()
{
    local group="${1}"

    if ( groups "${group}" > '/dev/null' 2>&1 )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function existUser()
{
    local user="${1}"

    if ( id --user "${user}" > '/dev/null' 2>&1 )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function generateUserSSHKey()
{
    local user="${1}"

    local userHome="$(getUserHomeFolder "${user}")"

    if [[ "$(isEmptyString "${userHome}")" = 'false' && -d "${userHome}" ]]
    then
        # Install Expect

        installExpectCommand

        # Generate SSH Key

        if [[ "$(existCommand 'expect')" = 'true' ]]
        then
            rm -f ${userHome}/.ssh/id_rsa*

            expect << DONE
                spawn su - ${user} --command 'ssh-keygen'
                expect "Enter file in which to save the key (*): "
                send -- "\r"
                expect "Enter passphrase (empty for no passphrase): "
                send -- "\r"
                expect "Enter same passphrase again: "
                send -- "\r"
                expect eof
DONE

            chmod 600 ${userHome}/.ssh/id_rsa*
        else
            fatal "\nFATAL: install 'expect' command failed!"
        fi
    else
        fatal "\nFATAL: home of user '${user}' not found!"
    fi
}

function getMachineDescription()
{
    lsb_release --short --description
}

function getMachineRelease()
{
    lsb_release --short --release
}

function getProfileFile()
{
    local user="${1}"

    local userHome="$(getUserHomeFolder "${user}")"

    if [[ "$(isEmptyString "${userHome}")" = 'false' && -d "${userHome}" ]]
    then
        local bashProfileFile="${userHome}/.bash_profile"
        local profileFile="${userHome}/.profile"
        local defaultStartUpFile="${bashProfileFile}"

        if [[ ! -f "${bashProfileFile}" && -f "${profileFile}" ]]
        then
            defaultStartUpFile="${profileFile}"
        fi

        echo "${defaultStartUpFile}"
    else
        echo
    fi
}

function getTemporaryFile()
{
    local extension="${1}"

    if [[ "$(isEmptyString "${extension}")" = 'false' && "$(echo "${extension}" | grep --ignore-case --only-matching "^.")" != '.' ]]
    then
        extension=".${extension}"
    fi

    mktemp "$(getTemporaryFolderRoot)/$(date +%m%d%Y_%H%M%S)_XXXXXXXXXX${extension}"
}

function getTemporaryFolder()
{
    mktemp --directory "$(getTemporaryFolderRoot)/$(date +%m%d%Y_%H%M%S)_XXXXXXXXXX"
}

function getTemporaryFolderRoot()
{
    local temporaryDirectory='/tmp'

    if [[ "$(isEmptyString "${TMPDIR}")" = 'false' ]]
    then
        temporaryDirectory="$(formatPath "${TMPDIR}")"
    fi

    echo "${temporaryDirectory}"
}

function getUserHomeFolder()
{
    local user="${1}"

    if [[ "$(isEmptyString "${user}")" = 'false' ]]
    then
        echo "$(eval "echo ~${user}")"
    else
        echo
    fi
}

function is64BitSystem()
{
    isMachineHardware 'x86_64'
}

function isDistributor()
{
    local distributor="${1}"

    local found="$(uname -v | grep --fixed-strings --ignore-case --only-matching "${distributor}")"

    if [[ "$(isEmptyString "${found}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function isLinuxOperatingSystem()
{
    isOperatingSystem 'Linux'
}

function isMachineHardware()
{
    local machineHardware="${1}"

    local found="$(uname -m | grep --extended-regexp --ignore-case --only-matching "^${machineHardware}$")"

    if [[ "$(isEmptyString "${found}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function isMacOperatingSystem()
{
    isOperatingSystem 'Darwin'
}

function isOperatingSystem()
{
    local operatingSystem="${1}"

    local found="$(uname -s | grep --extended-regexp --ignore-case --only-matching "^${operatingSystem}$")"

    if [[ "$(isEmptyString "${found}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function isPortOpen()
{
    local port="${1}"

    if [[ "$(isEmptyString "${port}")" = 'true' ]]
    then
        fatal "\nFATAL: port undefined"
    fi

    if [[ "$(isLinuxOperatingSystem)" = 'true' ]]
    then
        local process="$(netstat --listening --numeric --tcp --udp | grep --extended-regexp ":${port}\s+" | head -1)"
    elif [[ "$(isMacOperatingSystem)" = 'true' ]]
    then
        local process="$(lsof -i -n -P | grep --extended-regexp --ignore-case ":${port}\s+\(LISTEN\)$" | head -1)"
    else
        fatal "\nFATAL: operating system not supported"
    fi

    if [[ "$(isEmptyString "${process}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function isUbuntuDistributor()
{
    isDistributor 'Ubuntu'
}