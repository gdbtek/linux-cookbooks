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
    local addNewLine="${6}"

    # Validate Inputs

    checkExistFile "${file}"
    checkNonEmptyString "${pattern}" 'undefined pattern'
    checkNonEmptyString "${string}" 'undefined string'
    checkTrueFalseString "${patternAsRegex}"
    checkTrueFalseString "${stringAsRegex}"

    if [[ "${stringAsRegex}" = 'false' ]]
    then
        checkTrueFalseString "${addNewLine}"
    fi

    # Append String

    local grepOptions=('-F' '-o')

    if [[ "${patternAsRegex}" = 'true' ]]
    then
        grepOptions=('-E' '-o')
    fi

    local found="$(grep "${grepOptions[@]}" "${pattern}" "${file}")"

    if [[ "$(isEmptyString "${found}")" = 'true' ]]
    then
        if [[ "${stringAsRegex}" = 'true' ]]
        then
            echo -e "${string}" >> "${file}"
        else
            if [[ "${addNewLine}" = 'true' ]]
            then
                echo >> "${file}"
            fi

            echo "${string}" >> "${file}"
        fi
    fi
}

function checkValidJSONContent()
{
    local content="${1}"

    if [[ "$(isValidJSONContent "${content}")" = 'false' ]]
    then
        fatal "\nFATAL : invalid JSON"
    fi
}

function checkValidJSONFile()
{
    local file="${1}"

    if [[ "$(isValidJSONFile "${file}")" = 'false' ]]
    then
        fatal "\nFATAL : invalid JSON file '${file}'"
    fi
}

function createFileFromTemplate()
{
    local sourceFile="${1}"
    local destinationFile="${2}"
    local data=("${@:3}")

    checkExistFile "${sourceFile}"
    checkExistFolder "$(dirname "${destinationFile}")"

    local content="$(cat "${sourceFile}")"
    local i=0

    for ((i = 0; i < ${#data[@]}; i = i + 2))
    do
        local oldValue="$(escapeSearchPattern "${data[${i}]}")"
        local newValue="$(escapeSearchPattern "${data[${i} + 1]}")"

        content="$(sed "s@${oldValue}@${newValue}@g" <<< "${content}")"
    done

    echo "${content}" > "${destinationFile}"
}

function getFileExtension()
{
    local string="${1}"

    local fullFileName="$(basename "${string}")"

    echo "${fullFileName##*.}"
}

function getFileName()
{
    local string="${1}"

    local fullFileName="$(basename "${string}")"

    echo "${fullFileName%.*}"
}

function isValidJSONContent()
{
    local content="${1}"

    if ( python -m 'json.tool' <<< "${content}" &> '/dev/null' )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function isValidJSONFile()
{
    local file="${1}"

    checkExistFile "${file}"

    isValidJSONContent "$(cat "${file}")"
}

function symlinkLocalBin()
{
    local sourceBinFolder="${1}"

    find "${sourceBinFolder}" -maxdepth 1 -xtype f -perm -u+x -exec bash -c -e '
        for file
        do
            rm -f "/usr/local/bin/$(basename "${file}")"
            ln -s "${file}" "/usr/local/bin/$(basename "${file}")"
        done' bash {} \;
}

#########################
# FILE REMOTE UTILITIES #
#########################

function checkExistURL()
{
    local url="${1}"

    if [[ "$(existURL "${url}")" = 'false' ]]
    then
        fatal "\nFATAL : url '${url}' not found"
    fi
}

function downloadFile()
{
    local url="${1}"
    local destinationFile="${2}"
    local overwrite="${3}"

    checkExistURL "${url}"

    # Check Overwrite

    if [[ "$(isEmptyString "${overwrite}")" = 'true' ]]
    then
        overwrite='false'
    fi

    checkTrueFalseString "${overwrite}"

    # Validate

    if [[ -f "${destinationFile}" ]]
    then
        if [[ "${overwrite}" = 'true' ]]
        then
            rm -f "${destinationFile}"
        else
            fatal "\nFATAL : file '${destinationFile}' found"
        fi
    elif [[ -e "${destinationFile}" ]]
    then
        fatal "\nFATAL : file '${destinationFile}' exists"
    fi

    # Download

    debug "\nDownloading '${url}' to '${destinationFile}'"
    curl -L "${url}" -o "${destinationFile}"
}

function existURL()
{
    local url="${1}"

    # Install Curl

    installCURLCommand > '/dev/null'

    # Check URL

    if ( curl -f --head -L "${url}" -o '/dev/null' -s )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function getRemoteFileContent()
{
    local url="${1}"

    checkExistURL "${url}"
    curl -s -X 'GET' -L "${url}"
}

function unzipRemoteFile()
{
    local downloadURL="${1}"
    local installFolder="${2}"
    local extension="${3}"

    # Install Curl

    installCURLCommand

    # Validate URL

    checkExistURL "${downloadURL}"

    # Find Extension

    local exExtension=''

    if [[ "$(isEmptyString "${extension}")" = 'true' ]]
    then
        extension="$(getFileExtension "${downloadURL}")"
        exExtension="$(rev <<< "${downloadURL}" | cut -d '.' -f 1-2 | rev)"
    fi

    # Unzip

    if [[ "$(grep -i '^tgz$' <<< "${extension}")" != '' || "$(grep -i '^tar\.gz$' <<< "${extension}")" != '' || "$(grep -i '^tar\.gz$' <<< "${exExtension}")" != '' ]]
    then
        debug "\nDownloading '${downloadURL}'"
        curl -L "${downloadURL}" | tar -C "${installFolder}" -x -z --strip 1
        echo
    elif [[ "$(grep -i '^zip$' <<< "${extension}")" != '' ]]
    then
        # Install Unzip

        installUnzipCommand

        # Unzip

        if [[ "$(existCommand 'unzip')" = 'false' ]]
        then
            fatal "FATAL : command 'unzip' not found"
        fi

        local zipFile="${installFolder}/$(basename "${downloadURL}")"

        downloadFile "${downloadURL}" "${zipFile}" 'true'
        unzip -q "${zipFile}" -d "${installFolder}"
        rm -f "${zipFile}"
        echo
    else
        fatal "\nFATAL : file extension '${extension}' not supported"
    fi
}

#####################
# PACKAGE UTILITIES #
#####################

function getLastAptGetUpdate()
{
    local aptDate="$(stat -c %Y '/var/cache/apt')"
    local nowDate="$(date +'%s')"

    echo $((nowDate - aptDate))
}

function installAptGetPackage()
{
    local package="${1}"

    if [[ "$(isAptGetPackageInstall "${package}")" = 'true' ]]
    then
        debug "\nApt-Get Package '${package}' has already been installed"
    else
        echo -e "\033[1;35m\nInstalling Apt-Get package '${package}'\033[0m"
        apt-get install -y "${package}"
    fi
}

function installAptGetPackages()
{
    local packages=("${@}")

    runAptGetUpdate ''

    local package=''

    for package in "${packages[@]}"
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

    runAptGetUpdate ''

    local i=0

    for ((i = 0; i < ${#data[@]}; i = i + 2))
    do
        local command="${data[${i}]}"
        local package="${data[${i} + 1]}"

        checkNonEmptyString "${command}" 'undefined command'
        checkNonEmptyString "${package}" 'undefined package'

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
        debug "PIP Package '${package}' found"
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

    local found="$(dpkg --get-selections | grep -E -o "^${package}(:amd64)*\s+install$")"

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

    if [[ "$(existCommand 'pip')" = 'false' ]]
    then
        fatal "FATAL : command 'python-pip' not found"
    fi

    local found="$(pip list | grep -E -o "^${package}\s+\(.*\)$")"

    if [[ "$(isEmptyString "${found}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
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
        info "apt-get update"
        apt-get update -m
    else
        local lastUpdate="$(date -u -d @"${lastAptGetUpdate}" +'%-Hh %-Mm %-Ss')"

        info "\nSkip apt-get update because its last run was '${lastUpdate}' ago"
    fi
}

function runAptGetUpgrade()
{
    runAptGetUpdate ''

    info "\napt-get dist-upgrade"
    apt-get dist-upgrade -m -y

    info "\napt-get upgrade"
    apt-get upgrade -m -y

    info "\napt-get autoremove"
    apt-get autoremove -y
}

function upgradePIPPackage()
{
    local package="${1}"

    if [[ "$(isPIPPackageInstall "${package}")" = 'true' ]]
    then
        echo -e "\033[1;35mUpgrading PIP package '${package}'\033[0m"
        pip install --upgrade "${package}"
    else
        debug "PIP Package '${package}' not found"
    fi
}

####################
# STRING UTILITIES #
####################

function checkNonEmptyString()
{
    local string="${1}"
    local errorMessage="${2}"

    if [[ "$(isEmptyString "${string}")" = 'true' ]]
    then
        if [[ "$(isEmptyString "${errorMessage}")" = 'true' ]]
        then
            fatal "\nFATAL : empty value detected"
        else
            fatal "\nFATAL : ${errorMessage}"
        fi
    fi
}

function checkTrueFalseString()
{
    local string="${1}"

    if [[ "${string}" != 'true' && "${string}" != 'false' ]]
    then
        fatal "\nFATAL : '${string}' is not 'true' or 'false'"
    fi
}

function debug()
{
    local message="${1}"

    echo -e "\033[1;34m${message}\033[0m" 2>&1
}

function error()
{
    local message="${1}"

    echo -e "\033[1;31m${message}\033[0m" 1>&2
}

function escapeSearchPattern()
{
    local searchPattern="${1}"

    sed -e "s@\[@\\\\[@g" -e "s@\*@\\\\*@g" -e "s@\%@\\\\%@g" <<< "${searchPattern}"
}

function fatal()
{
    local message="${1}"

    error "${message}"
    exit 1
}

function formatPath()
{
    local path="${1}"

    while [[ "$(grep -F '//' <<< "${path}")" != '' ]]
    do
        path="$(sed -e 's/\/\/*/\//g' <<< "${path}")"
    done

    sed -e 's/\/$//g' <<< "${path}"
}

function header()
{
    local title="${1}"

    echo -e "\n\033[1;33m>>>>>>>>>> \033[1;4;35m${title}\033[0m \033[1;33m<<<<<<<<<<\033[0m\n"
}

function info()
{
    local message="${1}"

    echo -e "\033[1;36m${message}\033[0m" 2>&1
}

function invertTrueFalseString()
{
    local string="${1}"

    checkTrueFalseString "${string}"

    if [[ "${string}" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function isEmptyString()
{
    local string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function trimString()
{
    local string="${1}"

    sed -e 's/^ *//g' -e 's/ *$//g' <<< "${string}"
}

function warn()
{
    local message="${1}"

    echo -e "\033[1;33m${message}\033[0m" 1>&2
}

####################
# SYSTEM UTILITIES #
####################

function addUser()
{
    local userLogin="${1}"
    local groupName="${2}"
    local createHome="${3}"
    local systemAccount="${4}"
    local allowLogin="${5}"

    checkNonEmptyString "${userLogin}" 'undefined user login'
    checkNonEmptyString "${groupName}" 'undefined group name'

    # Options

    if [[ "${createHome}" = 'true' ]]
    then
        local createHomeOption=('-m')
    else
        local createHomeOption=('-M')
    fi

    if [[ "${systemAccount}" = 'false' ]]
    then
        local systemAccountOption=('')
    else
        local systemAccountOption=('-r')
    fi

    if [[ "${allowLogin}" = 'true' ]]
    then
        local allowLoginOption=('-s' '/bin/bash')
    else
        local allowLoginOption=('-s' '/bin/false')
    fi

    # Add Group

    groupadd -f -r "${groupName}"

    # Add User

    if [[ "$(existUserLogin "${userLogin}")" = 'true' ]]
    then
        if [[ "$(isUserLoginInGroupName "${userLogin}" "${groupName}")" = 'false' ]]
        then
            usermod -a -G "${groupName}" "${userLogin}"
        fi

        # Not Exist Home

        if [[ "${createHome}" = 'true' ]]
        then
            local userHome="$(getUserHomeFolder "${userLogin}")"

            if [[ "$(isEmptyString "${userHome}")" = 'true' || ! -d "${userHome}" ]]
            then
                mkdir -p "/home/${userLogin}"
                chown -R "${userLogin}:${groupName}" "/home/${userLogin}"
            fi
        fi
    else
        useradd "${createHomeOption[@]}" "${systemAccountOption[@]}" "${allowLoginOption[@]}" -g "${groupName}" "${userLogin}"
    fi
}

function addUserAuthorizedKey()
{
    local userLogin="${1}"
    local groupName="${2}"
    local sshRSA="${3}"

    configUserSSH "${userLogin}" "${groupName}" "${sshRSA}" 'authorized_keys'
}

function addUserSSHKnownHost()
{
    local userLogin="${1}"
    local groupName="${2}"
    local sshRSA="${3}"

    configUserSSH "${userLogin}" "${groupName}" "${sshRSA}" 'known_hosts'
}

function checkExistFile()
{
    local file="${1}"
    local errorMessage="${2}"

    if [[ "${file}" = '' || ! -f "${file}" ]]
    then
        if [[ "$(isEmptyString "${errorMessage}")" = 'true' ]]
        then
            fatal "\nFATAL : file '${file}' not found"
        else
            fatal "\nFATAL : ${errorMessage}"
        fi
    fi
}

function checkExistFolder()
{
    local folder="${1}"
    local errorMessage="${2}"

    if [[ "${folder}" = '' || ! -d "${folder}" ]]
    then
        if [[ "$(isEmptyString "${errorMessage}")" = 'true' ]]
        then
            fatal "\nFATAL : folder '${folder}' not found"
        else
            fatal "\nFATAL : ${errorMessage}"
        fi
    fi
}

function checkExistGroupName()
{
    local groupName="${1}"

    if [[ "$(existGroupName "${groupName}")" = 'false' ]]
    then
        fatal "\nFATAL : group name '${groupName}' not found"
    fi
}

function checkExistUserLogin()
{
    local userLogin="${1}"

    if [[ "$(existUserLogin "${userLogin}")" = 'false' ]]
    then
        fatal "\nFATAL : user login '${userLogin}' not found"
    fi
}

function checkRequirePort()
{
    local ports=("${@}")

    local headerRegex='^COMMAND\s\+PID\s\+USER\s\+FD\s\+TYPE\s\+DEVICE\s\+SIZE\/OFF\s\+NODE\s\+NAME$'
    local status="$(lsof -i -n -P | grep "\( (LISTEN)$\)\|\(${headerRegex}\)")"
    local open=''
    local port=''

    for port in "${ports[@]}"
    do
        local found="$(grep -i ":${port} (LISTEN)$" <<< "${status}")"

        if [[ "$(isEmptyString "${found}")" = 'false' ]]
        then
            open="${open}\n${found}"
        fi
    done

    if [[ "$(isEmptyString "${open}")" = 'false' ]]
    then
        echo -e    "\033[1;31mFollowing ports are still opened. Make sure you uninstall or stop them before a new installation!\033[0m"
        echo -e -n "\033[1;34m\n$(grep "${headerRegex}" <<< "${status}")\033[0m"
        echo -e    "\033[1;36m${open}\033[0m\n"
        exit 1
    fi
}

function checkRequireRootUser()
{
    checkRequireUserLogin 'root'
}

function checkRequireSystem()
{
    if [[ "$(isUbuntuDistributor)" = 'false' ]]
    then
        fatal "\nFATAL : non 'Ubuntu' OS found"
    fi

    if [[ "$(is64BitSystem)" = 'false' ]]
    then
        fatal "\nFATAL : non 'x86_64' OS found"
    fi
}

function checkRequireUserLogin()
{
    local userLogin="${1}"

    if [[ "$(whoami)" != "${userLogin}" ]]
    then
        fatal "\nFATAL : user login '${userLogin}' required"
    fi
}

function cleanUpSystemFolders()
{
    header "CLEANING UP SYSTEM FOLDERS"

    local folders=(
        '/tmp'
        '/var/tmp'
    )

    local folder=''

    for folder in "${folders[@]}"
    do
        echo "Cleaning up folder '${folder}'"
        emptyFolder "${folder}"
    done
}

function configUserGIT()
{
    local userLogin="${1}"
    local gitUserName="${2}"
    local gitUserEmail="${3}"

    header "CONFIGURING GIT FOR USER ${userLogin}"

    checkExistUserLogin "${userLogin}"
    checkNonEmptyString "${gitUserName}" 'undefined git user name'
    checkNonEmptyString "${gitUserEmail}" 'undefined git user email'

    su - "${userLogin}" -c "git config --global user.name '${gitUserName}'"
    su - "${userLogin}" -c "git config --global user.email '${gitUserEmail}'"
    su - "${userLogin}" -c 'git config --global push.default simple'

    info "$(su - "${userLogin}" -c 'git config --list')"
}

function configUserSSH()
{
    local userLogin="${1}"
    local groupName="${2}"
    local sshRSA="${3}"
    local configFileName="${4}"

    header "CONFIGURING ${configFileName} FOR USER ${userLogin}"

    checkExistUserLogin "${userLogin}"
    checkExistGroupName "${groupName}"
    checkNonEmptyString "${sshRSA}" 'undefined SSH-RSA'
    checkNonEmptyString "${configFileName}" 'undefined config file'

    local userHome="$(getUserHomeFolder "${userLogin}")"

    checkExistFolder "${userHome}"

    mkdir -p "${userHome}/.ssh"
    chmod 700 "${userHome}/.ssh"

    touch "${userHome}/.ssh/${configFileName}"
    appendToFileIfNotFound "${userHome}/.ssh/${configFileName}" "${sshRSA}" "${sshRSA}" 'false' 'false' 'false'
    chmod 600 "${userHome}/.ssh/${configFileName}"

    chown -R "${userLogin}:${groupName}" "${userHome}/.ssh"
}

function deleteUser()
{
    local userLogin="${1}"

    if [[ "$(existUserLogin "${userLogin}")" = 'true' ]]
    then
        userdel -f -r "${userLogin}" 2> '/dev/null'
    fi
}

function displayOpenPorts()
{
    header 'LIST OPEN PORTS'

    sleep 10
    lsof -i -n -P | grep -i ' (LISTEN)$' | sort -f
}

function emptyFolder()
{
    local folder="${1}"

    checkExistFolder "${folder}"

    local currentPath="$(pwd)"

    cd "${folder}"
    find '.' ! -name '.' -delete
    cd "${currentPath}"
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

function existDisk()
{
    local disk="${1}"

    local foundDisk="$(fdisk -l "${disk}" 2> '/dev/null' | grep -E -i -o "^Disk\s+$(escapeSearchPattern "${disk}"): ")"

    if [[ "$(isEmptyString "${disk}")" = 'false' && "$(isEmptyString "${foundDisk}")" = 'false' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function existDiskMount()
{
    local disk="${1}"
    local mountOn="${2}"

    local foundMount="$(df | grep -E "^${disk}\s+.*\s+${mountOn}$")"

    if [[ "$(isEmptyString "${foundMount}")" = 'true' ]]
    then
        echo 'false'
    else
        echo 'true'
    fi
}

function existGroupName()
{
    local group="${1}"

    if ( groups "${group}" > '/dev/null' 2>&1 )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function existUserLogin()
{
    local user="${1}"

    if ( id -u "${user}" > '/dev/null' 2>&1 )
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function generateUserSSHKey()
{
    local user="${1}"

    header "GENERATING SSH KEY FOR USER '${user}'"

    local userHome="$(getUserHomeFolder "${user}")"

    checkExistFolder "${userHome}"

    # Install Expect

    installExpectCommand

    # Generate SSH Key

    if [[ "$(existCommand 'expect')" = 'false' ]]
    then
        fatal "\nFATAL : command 'expect' not found"
    fi

    rm -f "${userHome}/.ssh/id_rsa" "${userHome}/.ssh/id_rsa.pub"

    expect << DONE
        spawn su - "${user}" -c 'ssh-keygen'

        expect "Enter file in which to save the key (*): "
        send -- "\r"

        expect "Enter passphrase (empty for no passphrase): "
        send -- "\r"

        expect "Enter same passphrase again: "
        send -- "\r"

        expect eof
DONE

    chmod 600 "${userHome}/.ssh/id_rsa" "${userHome}/.ssh/id_rsa.pub"
}

function getMachineDescription()
{
    lsb_release -d -s
}

function getMachineRelease()
{
    lsb_release -r -s
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

    if [[ "$(isEmptyString "${extension}")" = 'false' && "$(grep -i -o "^." <<< "${extension}")" != '.' ]]
    then
        extension=".${extension}"
    fi

    mktemp "$(getTemporaryFolderRoot)/$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX${extension}"
}

function getTemporaryFolder()
{
    mktemp -d "$(getTemporaryFolderRoot)/$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX"
}

function getTemporaryFolderRoot()
{
    local temporaryFolder='/tmp'

    if [[ "$(isEmptyString "${TMPDIR}")" = 'false' ]]
    then
        temporaryFolder="$(formatPath "${TMPDIR}")"
    fi

    echo "${temporaryFolder}"
}

function getUserHomeFolder()
{
    local user="${1}"

    if [[ "$(isEmptyString "${user}")" = 'false' ]]
    then
        local homeFolder="$(eval "echo ~${user}")"

        if [[ "${homeFolder}" = "\~${user}" ]]
        then
            echo
        else
            echo "${homeFolder}"
        fi
    else
        echo
    fi
}

function initializeFolder()
{
    local folder="${1}"

    if [[ -d "${folder}" ]]
    then
        emptyFolder "${folder}"
    else
        mkdir -p "${folder}"
    fi
}

function is64BitSystem()
{
    isMachineHardware 'x86_64'
}

function isDistributor()
{
    local distributor="${1}"

    local found="$(uname -v | grep -F -i -o "${distributor}")"

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

    local found="$(uname -m | grep -E -i -o "^${machineHardware}$")"

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

    local found="$(uname -s | grep -E -i -o "^${operatingSystem}$")"

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

    checkNonEmptyString "${port}" 'undefined port'

    if [[ "$(isLinuxOperatingSystem)" = 'true' ]]
    then
        local process="$(netstat -l -n -t -u | grep -E ":${port}\s+" | head -1)"
    elif [[ "$(isMacOperatingSystem)" = 'true' ]]
    then
        local process="$(lsof -i -n -P | grep -E -i ":${port}\s+\(LISTEN\)$" | head -1)"
    else
        fatal "\nFATAL : operating system not supported"
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

function isUserLoginInGroupName()
{
    local userLogin="${1}"
    local groupName="${2}"

    checkNonEmptyString "${userLogin}" 'undefined user login'
    checkNonEmptyString "${groupName}" 'undefined group name'

    if [[ "$(existUserLogin "${userLogin}")" = 'true' ]]
    then
        if [[ "$(groups "${userLogin}" | grep "\b${groupName}\b")" = '' ]]
        then
            echo 'false'
        else
            echo 'true'
        fi
    else
        echo 'false'
    fi
}