# paw_ansible_role_logstash
# @summary Manage paw_ansible_role_logstash configuration
#
# @param logstash_listen_port_beats
# @param logstash_ssl_dir
# @param logstash_local_syslog_path
# @param logstash_version
# @param logstash_package
# @param logstash_elasticsearch_hosts
# @param logstash_monitor_local_syslog
# @param logstash_dir
# @param logstash_ssl_certificate_file
# @param logstash_ssl_key_file
# @param logstash_enabled_on_boot
# @param logstash_install_plugins
# @param logstash_setup_default_config
# @param par_vardir Base directory for Puppet agent cache (uses lookup('paw::par_vardir') for common config)
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_logstash (
  Integer $logstash_listen_port_beats = 5044,
  String $logstash_ssl_dir = '/etc/pki/logstash',
  String $logstash_local_syslog_path = '/var/log/syslog',
  String $logstash_version = '7.x',
  String $logstash_package = 'logstash',
  Array $logstash_elasticsearch_hosts = ['http://localhost:9200'],
  Boolean $logstash_monitor_local_syslog = true,
  String $logstash_dir = '/usr/share/logstash',
  Optional[String] $logstash_ssl_certificate_file = undef,
  Optional[String] $logstash_ssl_key_file = undef,
  Boolean $logstash_enabled_on_boot = true,
  Array $logstash_install_plugins = ['logstash-input-beats', 'logstash-filter-multiline'],
  Boolean $logstash_setup_default_config = true,
  Optional[Stdlib::Absolutepath] $par_vardir = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
# Playbook synced via pluginsync to agent's cache directory
# Check for common paw::par_vardir setting, then module-specific, then default
$_par_vardir = $par_vardir ? {
  undef   => lookup('paw::par_vardir', Stdlib::Absolutepath, 'first', '/opt/puppetlabs/puppet/cache'),
  default => $par_vardir,
}
$playbook_path = "${_par_vardir}/lib/puppet_x/ansible_modules/ansible_role_logstash/playbook.yml"

par { 'paw_ansible_role_logstash-main':
  ensure        => present,
  playbook      => $playbook_path,
  playbook_vars => {
        'logstash_listen_port_beats' => $logstash_listen_port_beats,
        'logstash_ssl_dir' => $logstash_ssl_dir,
        'logstash_local_syslog_path' => $logstash_local_syslog_path,
        'logstash_version' => $logstash_version,
        'logstash_package' => $logstash_package,
        'logstash_elasticsearch_hosts' => $logstash_elasticsearch_hosts,
        'logstash_monitor_local_syslog' => $logstash_monitor_local_syslog,
        'logstash_dir' => $logstash_dir,
        'logstash_ssl_certificate_file' => $logstash_ssl_certificate_file,
        'logstash_ssl_key_file' => $logstash_ssl_key_file,
        'logstash_enabled_on_boot' => $logstash_enabled_on_boot,
        'logstash_install_plugins' => $logstash_install_plugins,
        'logstash_setup_default_config' => $logstash_setup_default_config
              },
  tags          => $par_tags,
  skip_tags     => $par_skip_tags,
  start_at_task => $par_start_at_task,
  limit         => $par_limit,
  verbose       => $par_verbose,
  check_mode    => $par_check_mode,
  timeout       => $par_timeout,
  user          => $par_user,
  env_vars      => $par_env_vars,
  logoutput     => $par_logoutput,
  exclusive     => $par_exclusive,
}
}
