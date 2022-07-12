# Docker build environment

Our docker scripts are built via the google cloud build service (using gcloud commands).

The cloud_build.sh script is a simple script that uses gcloud commands to run builds and save the builds on the google container registry.
See script help with the -h option.

We have configured a jenkins build job that uses the cloud_build.sh.

## GCP cloud build CLI script

    cloud_build.sh -h

## Authenticate with Google Container Registry service account.

This should be performed within the build environment in order to download images from gcr to your local machine for testing.
The key should be securely stored in the Jenkins Credential Manager

    service_account_key="YOUR_SERVICE_ACCOUNT_JSON"
    
    docker login -u _json_key -p "$(cat ${script_dir}/../auth/${service_account_key})" https://us.gcr.io
