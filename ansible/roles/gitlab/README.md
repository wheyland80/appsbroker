GitLab
======

This role installs and configures gitlab under a docker-compose environment

GitLab installation: https://docs.gitlab.com/ee/install/docker.html
Memory constrained configs: https://docs.gitlab.com/omnibus/settings/memory_constrained_envs.html

Default password can be found in the web container after installation

web_1  | Default admin account has been configured with following details:
web_1  | Username: root
web_1  | Password: You didn't opt-in to print initial root password to STDOUT.
web_1  | Password stored to /etc/gitlab/initial_root_password. This file will be cleaned up in first reconfigure run after 24 hours.

Client Configuration
--------------------

Our gitlab endpoint gitlab.voliaoffice.co.uk uses a custom port 2222. In order to default to port 2222 when clone and pushing git repositories you need to set the default port for this host to 2222

Add the following to your ~/.ssh/config file

    Host gitlab.voliaoffice.co.uk
        User git
        Port 2222

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
