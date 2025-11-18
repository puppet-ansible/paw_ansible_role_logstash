#!/bin/bash
set -e

# Puppet task for executing Ansible role: ansible_role_logstash
# This script runs the entire role via ansible-playbook

# Determine the ansible modules directory
if [ -n "$PT__installdir" ]; then
  ANSIBLE_DIR="$PT__installdir/lib/puppet_x/ansible_modules/ansible_role_logstash"
else
  # Fallback to /opt/puppetlabs/puppet/cache/lib/puppet_x/ansible_modules
  ANSIBLE_DIR="/opt/puppetlabs/puppet/cache/lib/puppet_x/ansible_modules/ansible_role_logstash"
fi

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
  echo '{"_error": {"msg": "ansible-playbook command not found. Please install Ansible.", "kind": "puppet-ansible-converter/ansible-not-found"}}'
  exit 1
fi

# Check if the role directory exists
if [ ! -d "$ANSIBLE_DIR" ]; then
  echo "{\"_error\": {\"msg\": \"Ansible role directory not found: $ANSIBLE_DIR\", \"kind\": \"puppet-ansible-converter/role-not-found\"}}"
  exit 1
fi

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
if [ -d "$ANSIBLE_DIR/roles" ] && [ -f "$ANSIBLE_DIR/roles/paw_ansible_role_logstash/playbook.yml" ]; then
  # Collection structure
  PLAYBOOK_PATH="$ANSIBLE_DIR/roles/paw_ansible_role_logstash/playbook.yml"
  PLAYBOOK_DIR="$ANSIBLE_DIR/roles/paw_ansible_role_logstash"
elif [ -f "$ANSIBLE_DIR/playbook.yml" ]; then
  # Standalone role structure
  PLAYBOOK_PATH="$ANSIBLE_DIR/playbook.yml"
  PLAYBOOK_DIR="$ANSIBLE_DIR"
else
  echo "{\"_error\": {\"msg\": \"playbook.yml not found in $ANSIBLE_DIR or $ANSIBLE_DIR/roles/paw_ansible_role_logstash\", \"kind\": \"puppet-ansible-converter/playbook-not-found\"}}"
  exit 1
fi

# Build extra-vars from PT_* environment variables (excluding par_* control params)
EXTRA_VARS="{"
FIRST=true
if [ -n "$PT_logstash_listen_port_beats" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_listen_port_beats\": \"$PT_logstash_listen_port_beats\""
fi
if [ -n "$PT_logstash_ssl_dir" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_ssl_dir\": \"$PT_logstash_ssl_dir\""
fi
if [ -n "$PT_logstash_local_syslog_path" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_local_syslog_path\": \"$PT_logstash_local_syslog_path\""
fi
if [ -n "$PT_logstash_version" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_version\": \"$PT_logstash_version\""
fi
if [ -n "$PT_logstash_package" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_package\": \"$PT_logstash_package\""
fi
if [ -n "$PT_logstash_elasticsearch_hosts" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_elasticsearch_hosts\": \"$PT_logstash_elasticsearch_hosts\""
fi
if [ -n "$PT_logstash_monitor_local_syslog" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_monitor_local_syslog\": \"$PT_logstash_monitor_local_syslog\""
fi
if [ -n "$PT_logstash_dir" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_dir\": \"$PT_logstash_dir\""
fi
if [ -n "$PT_logstash_ssl_certificate_file" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_ssl_certificate_file\": \"$PT_logstash_ssl_certificate_file\""
fi
if [ -n "$PT_logstash_ssl_key_file" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_ssl_key_file\": \"$PT_logstash_ssl_key_file\""
fi
if [ -n "$PT_logstash_enabled_on_boot" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_enabled_on_boot\": \"$PT_logstash_enabled_on_boot\""
fi
if [ -n "$PT_logstash_install_plugins" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_install_plugins\": \"$PT_logstash_install_plugins\""
fi
if [ -n "$PT_logstash_setup_default_config" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"logstash_setup_default_config\": \"$PT_logstash_setup_default_config\""
fi
EXTRA_VARS="$EXTRA_VARS}"

# Build ansible-playbook command matching PAR provider exactly
# See: https://github.com/garrettrowell/puppet-par/blob/main/lib/puppet/provider/par/par.rb#L166
cd "$PLAYBOOK_DIR"

# Base command with inventory and connection (matching PAR)
ANSIBLE_CMD="ansible-playbook -i localhost, --connection=local"

# Add extra-vars (playbook variables)
ANSIBLE_CMD="$ANSIBLE_CMD -e \"$EXTRA_VARS\""

# Add tags if specified
if [ -n "$PT_par_tags" ]; then
  TAGS=$(echo "$PT_par_tags" | sed 's/\[//;s/\]//;s/"//g;s/,/,/g')
  ANSIBLE_CMD="$ANSIBLE_CMD --tags \"$TAGS\""
fi

# Add skip-tags if specified
if [ -n "$PT_par_skip_tags" ]; then
  SKIP_TAGS=$(echo "$PT_par_skip_tags" | sed 's/\[//;s/\]//;s/"//g;s/,/,/g')
  ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags \"$SKIP_TAGS\""
fi

# Add start-at-task if specified
if [ -n "$PT_par_start_at_task" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --start-at-task \"$PT_par_start_at_task\""
fi

# Add limit if specified
if [ -n "$PT_par_limit" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$PT_par_limit\""
fi

# Add verbose flag if specified
if [ "$PT_par_verbose" = "true" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD -v"
fi

# Add check mode flag if specified
if [ "$PT_par_check_mode" = "true" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --check"
fi

# Add user if specified
if [ -n "$PT_par_user" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --user \"$PT_par_user\""
fi

# Add timeout if specified
if [ -n "$PT_par_timeout" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --timeout $PT_par_timeout"
fi

# Add playbook path as last argument (matching PAR)
ANSIBLE_CMD="$ANSIBLE_CMD playbook.yml"

# Set environment variables if specified (matching PAR env_vars handling)
if [ -n "$PT_par_env_vars" ]; then
  # Parse JSON hash and export variables
  eval $(echo "$PT_par_env_vars" | sed 's/[{}]//g;s/": "/=/g;s/","/;export /g;s/"//g' | sed 's/^/export /')
fi

# Set required Ansible environment (matching PAR)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export ANSIBLE_STDOUT_CALLBACK=json

# Execute ansible-playbook
eval $ANSIBLE_CMD 2>&1

EXIT_CODE=$?

# Return JSON result
if [ $EXIT_CODE -eq 0 ]; then
  echo '{"status": "success", "role": "ansible_role_logstash"}'
else
  echo "{\"status\": \"failed\", \"role\": \"ansible_role_logstash\", \"exit_code\": $EXIT_CODE}"
fi

exit $EXIT_CODE
