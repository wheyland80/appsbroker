#!/usr/bin/env groovy
// vars/fetchTerraformSecrets.groovy

import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey
import org.jenkinsci.plugins.plaincredentials.StringCredentials
import org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl

@NonCPS
def call() {
    def debug_option = ''
    if ( params.DEBUG == true )
    {
        debug_option = '-d'
    }

    // Fetch secrets from Google Secret Manager and convert to an ansible yaml format
    // Write secrets to a ./ansible/secrets.yml file

    return true
}
