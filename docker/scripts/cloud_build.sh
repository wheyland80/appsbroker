#!/usr/bin/env bash

# AUTHOR: William Heyland
# DESCRIPTION: Build a docker image on the Google Container Cloud Build service and push the image to a private google container registry

# ENVIRONMENT
# ===========
IMAGE=${IMAGE:-}
VERSION=${VERSION:-}

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

# Exit on unhandled error
set -e

# CONFIGURATION
# =============

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
NAME
    build.sh - Build an image.

    Build an image (-i IMAGE)

SYNOPSIS
    build.sh [-h] [-d] -e ENVIRONMENT -i IMAGE [-v VERSION ]

OPTIONS
    -h
        Display this inbuilt help
    -d
        Enable debug mode.
    -i IMAGE
        The target image (nginx, mysql, rabbitmq, php, redis, devtools, ...)
    -v VERSION
        The image VERSION (Docker TAG). If you don't specify a version, the next available version will be automatically used.

EXAMPLES
    Build a 'nginx' image from Dockerfile under the './dockerfiles/nginx/' directory with 'dev' environment configuration

        ./build.sh -i jenkins
"

debug_command='echo'

# FUNCTIONS
# =========

# std output
function output_stdout {
    echo
    echo -e "${1}"
    return 0
}

# Error output
function output_stderr {
    >&2 echo
    >&2 echo -e "${1}"
}

# Validate cluster
function validate_cluster {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9-]+$' \
        || { output_stderr "Invalid cluster (-c '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate config_file
function validate_config_file {
    if [ ! -f "${config_file}" ]
    then
      output_stderr "Missing config file '${config_file}'";
      output_stdout "${inbuilt_help}";
      exit 1;
    fi
}

# Validate environment
function validate_environment {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9]+$' \
        || { output_stderr "Invalid environment (-e '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate image
function validate_image {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9-]+$' \
        || { output_stderr "Invalid image (-i '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate namespace
function validate_namespace {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9_-]+$' \
        || { output_stderr "Invalid namespace (-n '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate path to image directory. Ensure the directory exists
function validate_path_to_image_dir {
    if [ ! -d "${1}" ]
    then
      output_stderr "No such directory (-s '${1}')";
      output_stdout "${inbuilt_help}";
      exit 1;
    fi
}

# Validate version
function validate_version {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9_-]+$' \
        || { output_stderr "Invalid version (-v '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate Google Compute Engine Project Id
function validate_gce_project_id {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9_-]+$' \
        || { output_stderr "Invalid GCE Project ID (-g '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate Google Container Registry Docker Repository
function validate_gcr_repository {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_-]+$' \
        || { output_stderr "Invalid GCR Docker Repository (-r '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# Validate zone
function validate_zone {
    echo "${1}" | grep -Eq '^[a-zA-Z0-9-]+$' \
        || { output_stderr "Invalid zone (-z '${1}')";
            output_stdout "${inbuilt_help}";
            exit 1; }
}

# PROCESS SCRIPT ARGUMENTS
# ========================
while getopts 'hde:i:v:' opt
do
    case $opt in
        d)
            debug="${debug_command}";
            ;;
        i)
            IMAGE="${OPTARG}"
            ;;
        v)
            VERSION="${OPTARG}"
            ;;
        h)
            # Display help and exit
            output_stdout "${inbuilt_help}"
            exit 0
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
validate_image "${IMAGE}"

# Load configuration
# Later values will override earlier entries
if [ -f "${script_dir}/../config/config.sh" ]
then
    source "${script_dir}/../config/config.sh"
fi

if [ -n "${VERSION}" ]
then
    validate_version "${VERSION}"
fi

# GETTING DOWN TO BUSINESS
# ========================

# Exit on unhandled error
set -ex

# Path to Dockerfile
path_to_dockerfile_dir="${script_dir}/../dockerfiles/${IMAGE}"

# Change working directory to dockerfile
cd "${path_to_dockerfile_dir}"

# The image name
image_name="${IMAGE}"

if [ -z "${VERSION}" ]
then
    # Fetch a list of image versions (tags)
    latest_version=$(gcloud container images --format='value(tags)' list-tags "${config_gcr_repository}/${image_name}" | grep -Eo '^[0-9]+\b' | sort -nr | head -n 1 )

    VERSION=1
    if [ -n "${latest_version}" ]
    then
        let VERSION=${latest_version}+1
    fi
fi

# Run the pre-build script, if present
# This is useful for setting build environment variables
if [ -f "${path_to_dockerfile_dir}/pre_build.sh" ]
then
    output_stdout "${bold}Running Pre-Build script 'pre_build.sh'${normal}"

    source "${path_to_dockerfile_dir}/pre_build.sh"
fi

# Build the image
output_stdout "${bold}Building image '${image_name}'${normal}"
${debug} gcloud builds submit --config="${path_to_dockerfile_dir}/cloudbuild.yaml" --substitutions="_VERSION=${VERSION}" "${path_to_dockerfile_dir}/" \
    || { output_stderr "Failed to build image '${image_name}'"; exit 1; }

# Run the post-build script, if present
# Use this to cleanup the build environment if necessary. Note that Jenkins should be setup to work from a clean workspace so this should only be necessary in rare situations
if [ -f "${path_to_dockerfile_dir}/post_build.sh" ]
then
    output_stdout "${bold}Running Post-Build script 'pre_build.sh'${normal}"

    source "${path_to_dockerfile_dir}/post_build.sh"
fi
