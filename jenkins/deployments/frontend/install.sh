#!/usr/bin/env bash

# Title: Install Frontend Package
# Author: William Heyland
# Description: Install 'frontend' package from google storage.

# ENVIRONMENT
# ===========

# Supported environment variables and default values
BASE_DEPLOY_PATH=${BASE_DEPLOY_PATH:-/home/codedeploy/sites}
BUILD_SOURCE=${BUILD_SOURCE:-sidekick}
PROJECT_NAME=${PROJECT_NAME:-frontend}
GIT_BRANCH=${GIT_BRANCH:-}
BUILD_ID=${BUILD_ID:-}

# The name of the script invoked by the user from the command line. This could be different to the name of this file if the user invoked the script via a symbolic link.
script_name=$(basename "$0")

# Current working directory
current_working_dir=$(pwd)

# Fully de-referenced script path in case of sym-link
script_path="${BASH_SOURCE[0]}"
while [ -h "$script_path" ]; do # resolve $source until the file is no longer a sym-link
  script_dir="$( cd -P "$( dirname "$script_path" )" && pwd )"
  script_path="$(readlink "$script_path")"
  [[ $script_path != /* ]] && script_path="$script_dir/$script_path" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Script directory. Important for locating includes and configs
script_dir="$( cd -P "$( dirname "$script_path" )" && pwd )"

# CONFIGURATION
# =============

# Script must be run as the following user
enforce_script_username='codedeploy'

base_build_artifact_url="gs://code-builds"
gsutil_cmd=/usr/bin/gsutil

archive_name=
build_artifact_url=

debug=
debug_command='echo'

# Formatting escape sequences
bold=
underline=
standout=
normal=
black=
red=
green=
yellow=
blue=
magenta=
cyan=
white=
default_color=
# check if stdout is a terminal...
if [ -t 1 ]
then

    # see if it supports colors...
    ncolors=$(tput colors)

    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]
    then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
        default_color=$(tput setaf 9)
    fi
fi

# Command Help
inbuilt_help="
${bold}NAME${normal}
    ${script_name} - Install Website Package.

    Install 'website' package from google storage.

${bold}SYNOPSIS${normal}
    ${script_name} [-h] [-d] [-o ARG] ....

${bold}OPTIONS${normal}
    ${bold}-h${normal}
        Display this inbuilt help.
    ${bold}-d${normal}
        Enable debug mode. In debug mode do not run any commands, instead output the commands that would be executed.
    ${bold}-s${normal} BUILD_SOURCE
        The source of the build (sidekick, jenkins, or misc).
    ${bold}-n${normal} PROJECT_NAME
        Friendly project name.
    ${bold}-b${normal} GIT_BRANCH
        Git branch.
    ${bold}-i${normal} BUILD_ID
        Build ID, unique from all other builds.
    ${bold}-p${normal} BASE_DEPLOY_PATH
        The base deployment path.
    ${bold}-k${normal} PRIVATE_RSA_KEY_PATH
        Private RSA key file path.
"

# FUNCTION DECLARATIONS
# =====================

# std output
function output_stdout {
    echo
    echo -e "${1}"
}

# Error output
function output_stderr {
    >&2 echo
    >&2 echo -e "${1}"
}

# Validate option
function validate_build_id {
    echo "${1}" | grep -Eq '^[0-9]+$' \
        || { output_stderr "${red}Invalid build id (-i ${1})${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate build source
function validate_build_source {
    echo "${1}" | grep -Eq '^jenkins|sidekick|misc$' \
        || { output_stderr "${red}Invalid build source (-s ${1})${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate git branch
function validate_git_branch {
    echo "${1}" | grep -Eq '^.+$' \
        || { output_stderr "${red}Invalid git branch (-b ${1})${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate project name
function validate_project_name {
    echo "${1}" | grep -Eq '^.+$' \
        || { output_stderr "${red}Invalid project name (-n ${1})${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate gs_package_url
function validate_build_artifact_url {
    echo "${1}" | grep -Pq 'gs://code-builds/(sidekick|jenkins|misc)/[a-zA-Z0-9-]+/[a-zA-Z0-9-]+/[0-9-]+\.tar\.gz$' \
        || { output_stderr "${red}Invalid build artifact url (-u '${1}')${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }

    # Ensure the package exists
    ${gsutil_cmd} -q stat "${1}" \
        || {
        output_stderr "${red}Artifact file does not exist ${1}${normal}";
        output_stdout "${inbuilt_help}";
        exit 1;
        }
}

# Validate private rsa key path
function validate_private_rsa_key_path {
    test -f ${1} \
        || { output_stderr "${red}Invalid private rsa key path (-n ${1})${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate base deploy path
function validate_base_deploy_path {
    test -d ${1} \
        || { output_stderr "${red}Invalid base deploy path (-p ${1})${normal}";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# SANITY/DEPENDENCY CHECKS
# ========================

# Only run as the codedeploy user
if [ "$(whoami)" != "${enforce_script_username}" ]; then
        echo "Script must be run as user: ${enforce_script_username}"
        exit -1
fi

# PROCESS SCRIPT ARGUMENTS
# ========================
while getopts 'dhs:i:b:n:p:k:' opt
do
    case $opt in
        d)
            debug=${debug_command};
            ;;
        s)
            BUILD_SOURCE="${OPTARG}"
            ;;
        h)
            # Display help and exit
            output_stdout "${inbuilt_help}"
            exit 0
            ;;
        i)
            BUILD_ID="${OPTARG}"
            ;;
        b)
            GIT_BRANCH="${OPTARG}"
            ;;
        n)
            PROJECT_NAME="${OPTARG}"
            ;;
        p)
            BASE_DEPLOY_PATH="${OPTARG}"
            ;;
        k)
            PRIVATE_RSA_KEY_PATH="${OPTARG}"
            ;;
        \?)
            # Display help and exit with error status code 1
            output_stderr "Invalid option: -$opt"
            output_stdout "${inbuilt_help}"
            exit 1
            ;;
    esac
done

# INPUT VALIDATION
# ================
validate_build_source "${BUILD_SOURCE}"
validate_project_name "${PROJECT_NAME}"
validate_git_branch "${GIT_BRANCH}"
validate_build_id "${BUILD_ID}"
validate_base_deploy_path "${BASE_DEPLOY_PATH}"
validate_private_rsa_key_path "${PRIVATE_RSA_KEY_PATH}"

archive_name="${BUILD_ID}.tar.gz"
build_artifact_url="${base_build_artifact_url}/${BUILD_SOURCE}/${PROJECT_NAME}/${GIT_BRANCH}/${archive_name}"
validate_build_artifact_url "${build_artifact_url}"

# GETTING DOWN TO BUSINESS
# ========================

# Display commands being run and exit following error
set -ex

# Create the deployment path
deploy_path="${BASE_DEPLOY_PATH}/frontend/${GIT_BRANCH}/${BUILD_ID}"
${debug} mkdir -p "${deploy_path}"

# Pull down the package
${debug} ${gsutil_cmd} cp "${build_artifact_url}" "${BASE_DEPLOY_PATH}/${archive_name}"

# Untar the package
${debug} tar -C "${deploy_path}" -xzvf  "${BASE_DEPLOY_PATH}/${archive_name}"

# Decrypt the configs
${debug} /usr/bin/php "${BASE_DEPLOY_PATH}/decrypt_config_file.php" -c "${deploy_path}/conf" -p "${PRIVATE_RSA_KEY_PATH}"

# Remove archive
${debug} rm -f "${BASE_DEPLOY_PATH}/${archive_name}"

# Update the symlinks to point to the new package
${debug} mkdir -p "${BASE_DEPLOY_PATH}/frontend" "${BASE_DEPLOY_PATH}/cc" "${BASE_DEPLOY_PATH}/www" "${BASE_DEPLOY_PATH}/my" "${BASE_DEPLOY_PATH}/login" "${BASE_DEPLOY_PATH}/signup" "${BASE_DEPLOY_PATH}/shorturl" "${BASE_DEPLOY_PATH}/support"
${debug} ln -fns ${deploy_path} ${BASE_DEPLOY_PATH}/frontend/live
${debug} ln -fns ${deploy_path}/cc ${BASE_DEPLOY_PATH}/cc/live
${debug} ln -fns ${deploy_path}/my ${BASE_DEPLOY_PATH}/my/live
${debug} ln -fns ${deploy_path}/www ${BASE_DEPLOY_PATH}/www/live
${debug} ln -fns ${deploy_path}/login ${BASE_DEPLOY_PATH}/login/live
${debug} ln -fns ${deploy_path}/signup ${BASE_DEPLOY_PATH}/signup/live;
${debug} ln -fns ${deploy_path}/shorturl ${BASE_DEPLOY_PATH}/shorturl/live
${debug} ln -fns ${deploy_path}/support ${BASE_DEPLOY_PATH}/support/live

# Restart php services if active
if sudo systemctl is-active --quiet php7.4-fpm
then
    ${debug} sudo systemctl restart php7.4-fpm
fi

if sudo systemctl is-active --quiet php7.3-fpm
then
    ${debug} sudo systemctl restart php7.3-fpm
fi

if sudo systemctl is-active --quiet php5.6-fpm
then
    ${debug} sudo systemctl restart php5.6-fpm
fi

# Remove versions older than 100 days
# ${debug} find "${BASE_DEPLOY_PATH}" -maxdepth 1 -type d ! -iname "${deploy_path}" -mtime +100 -exec rm -rf {} \;
