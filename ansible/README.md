# Ansible environment

This ansible simple appsbroker project is structured with a single site.yml and includes roles based on host or hostgroup.

## Common ansible commands

### Run ansible playbook against a single target host

Use --list-sites to list all known hosts (all hosts in inventory)

    ansible-playbook --list-hosts ./site.yml
    
Use --limit=host to run ansible-playbook against a single target host

    ansible-playbook --limit=ladybird ./site.yml
    
### Initialise a new role

Initialise a new role.
NOTE: There are templates available for other role types including 'docker'

    role_name='ROLENAME'
    ansible-galaxy role init "${role_name}" --init-path=./roles/

### Determine all available FACTS

To get a list of facts of a remove host

    host=jenkins
    ansible $host -m ansible.builtin.setup
