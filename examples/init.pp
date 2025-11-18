# Example usage of paw_ansible_role_logstash

# Simple include with default parameters
include paw_ansible_role_logstash

# Or with custom parameters:
# class { 'paw_ansible_role_logstash':
#   logstash_listen_port_beats => 5044,
#   logstash_ssl_dir => '/etc/pki/logstash',
#   logstash_local_syslog_path => '/var/log/syslog',
#   logstash_version => '7.x',
#   logstash_package => 'logstash',
#   logstash_elasticsearch_hosts => ['http://localhost:9200'],
#   logstash_monitor_local_syslog => true,
#   logstash_dir => '/usr/share/logstash',
#   logstash_ssl_certificate_file => undef,
#   logstash_ssl_key_file => undef,
#   logstash_enabled_on_boot => true,
#   logstash_install_plugins => ['logstash-input-beats', 'logstash-filter-multiline'],
#   logstash_setup_default_config => true,
# }
