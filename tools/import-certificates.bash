#!/bin/bash -e

#############
# CONSTANTS #
#############

DEFAULT_CA_TRUST_ANCHORS='/etc/pki/ca-trust/source/anchors'
DEFAULT_JAVA_HOME='/opt/jdk'

##################
# IMPLEMENTATION #
##################

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e '\033[1;33m'
    echo    'SYNOPSIS :'
    echo    "  ${scriptName}"
    echo    '    --help'
    echo    '    --import-certificate    <IMPORT_CERTIFICATE>'
    echo    '    --ca-trust-anchors      <CA_TRUST_ANCHORS>'
    echo    '    --java-home             <JAVA_HOME>'
    echo    '    --store-password        <STORE_PASSWORD>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help                  Help page (optional)'
    echo    '  --import-certificate    Path to source certificate folder path (require)'
    echo    '  --store-password        Store password (require)'
    echo    '  --ca-trust-anchors      Path to destination CA-Trust Anchors folder path (optional)'
    echo    "                          Default to '${DEFAULT_CA_TRUST_ANCHORS}'"
    echo    '  --java-home             Path to destination Java Home folder path (optional)'
    echo    "                          Default to '${DEFAULT_JAVA_HOME}'"
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --import-certificate '/downloads/ssl' --store-password 'abc123'"
    echo    "  ./${scriptName} --import-certificate '/downloads/ssl' --store-password 'abc123' --java-home '/opt/jre'"
    echo    "  ./${scriptName} --import-certificate '/downloads/ssl' --store-password 'abc123' --ca-trust-anchors '/path/anchors' --java-home '/opt/jre'"
    echo -e '\033[0m'

    exit "${1}"
}

function importCertificates()
{
    local -r importCertificate="${1}"
    local -r caTrustAnchors="${2}"
    local -r javaHome="${3}"
    local -r storePassword="${4}"

    local -r oldIFS="${IFS}"
    IFS=$'\n'

    local certificateFilePath=''

    for certificateFilePath in $(find -L "${importCertificate}" -type f -name '*.crt' | sort -f)
    do
        local certificateName="$(getFileName "${certificateFilePath}")"

        keytool \
            -delete \
            -noprompt \
            -trustcacerts \
            -alias "${certificateName}" \
            -keystore "${javaHome}/lib/security/cacerts" \
            -storepass "${storePassword}" || true

        keytool \
            -import \
            -noprompt \
            -trustcacerts \
            -alias "${certificateName}" \
            -file "${certificateFilePath}" \
            -keystore "${javaHome}/lib/security/cacerts" \
            -storepass "${storePassword}"

        cp -f "${certificateFilePath}" "${caTrustAnchors}"
    done

    IFS="${oldIFS}"

    update-ca-trust enable
    update-ca-trust extract
}

########
# MAIN #
########

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    # Parsing Command Arguments

    local -r optCount="${#}"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --import-certificate)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local importCertificate=''
                    importCertificate="$(formatPath ${1})"
                fi

                ;;

            --ca-trust-anchors)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local caTrustAnchors=''
                    caTrustAnchors="$(formatPath ${1})"
                fi

                ;;

            --java-home)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local javaHome=''
                    javaHome="$(formatPath ${1})"
                fi

                ;;

            --store-password)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local storePassword="${1}"
                fi

                ;;

            *)
                shift
                ;;
        esac
    done

    # Validate Opt

    if [[ "${optCount}" -lt '1' ]]
    then
        displayUsage 0
    fi

    # Default Values

    if [[ "$(isEmptyString "${caTrustAnchors}")" = 'true' ]]
    then
        caTrustAnchors="${DEFAULT_CA_TRUST_ANCHORS}"
    fi

    if [[ "$(isEmptyString "${javaHome}")" = 'true' ]]
    then
        javaHome="${DEFAULT_JAVA_HOME}"
    fi

    # Validation

    checkExistFolder "${importCertificate}"
    checkExistFolder "${caTrustAnchors}"
    checkExistFolder "${javaHome}"

    checkNonEmptyString "${storePassword}" 'undefined store password'

    # Start Importing

    importCertificates "${importCertificate}" "${caTrustAnchors}" "${javaHome}" "${storePassword}"
}

main "${@}"