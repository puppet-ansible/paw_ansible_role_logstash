# Puppet task for executing Ansible role: ansible_role_logstash
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_logstash"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_logstash"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_logstash\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_logstash"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_logstash"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_logstash_listen_port_beats) {
  $ExtraVars['logstash_listen_port_beats'] = $env:PT_logstash_listen_port_beats
}
if ($env:PT_logstash_ssl_dir) {
  $ExtraVars['logstash_ssl_dir'] = $env:PT_logstash_ssl_dir
}
if ($env:PT_logstash_local_syslog_path) {
  $ExtraVars['logstash_local_syslog_path'] = $env:PT_logstash_local_syslog_path
}
if ($env:PT_logstash_version) {
  $ExtraVars['logstash_version'] = $env:PT_logstash_version
}
if ($env:PT_logstash_package) {
  $ExtraVars['logstash_package'] = $env:PT_logstash_package
}
if ($env:PT_logstash_elasticsearch_hosts) {
  $ExtraVars['logstash_elasticsearch_hosts'] = $env:PT_logstash_elasticsearch_hosts
}
if ($env:PT_logstash_monitor_local_syslog) {
  $ExtraVars['logstash_monitor_local_syslog'] = $env:PT_logstash_monitor_local_syslog
}
if ($env:PT_logstash_dir) {
  $ExtraVars['logstash_dir'] = $env:PT_logstash_dir
}
if ($env:PT_logstash_ssl_certificate_file) {
  $ExtraVars['logstash_ssl_certificate_file'] = $env:PT_logstash_ssl_certificate_file
}
if ($env:PT_logstash_ssl_key_file) {
  $ExtraVars['logstash_ssl_key_file'] = $env:PT_logstash_ssl_key_file
}
if ($env:PT_logstash_enabled_on_boot) {
  $ExtraVars['logstash_enabled_on_boot'] = $env:PT_logstash_enabled_on_boot
}
if ($env:PT_logstash_install_plugins) {
  $ExtraVars['logstash_install_plugins'] = $env:PT_logstash_install_plugins
}
if ($env:PT_logstash_setup_default_config) {
  $ExtraVars['logstash_setup_default_config'] = $env:PT_logstash_setup_default_config
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_logstash"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_logstash"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}
