# == Class varnishkafka
# Configures and runs varnishkafka Varnish to Kafka producer.
# See: https://github.com/wikimedia/varnishkafka
# Most varnishkafka.conf properties are supported.
#
# == Parameters
# $brokers                          - Array of Kafka broker host:ports.
#                                     Default: [localhost:9091]
# $topic                            - Kafka topic name to produce to.
#                                     Default: varnish
# $sequence_number                  - Sequence number at which to start logging.
#                                     You can set this to an arbitrary integer, or to
#                                     'time', which will start the sequence number
#                                     at the current timestamp * 10000000. Default: 0
# $output                           - output type.  Either 'kafka', 'stdout', or 'null'.
#                                     Default: kafka
# $format_type                      - Log format type.  Either 'string' or 'json'
#                                     Default: string
# $format                           - Log format string.
# $format_key_type                  - Kafka message key format type.
#                                     Either 'string' or 'json'.  Default: string
# $format_key                       - Kafka message key format string.
#                                     Default: undef (disables Kafka message key usage).
# $partition                        - Topic partition number to send to.  -1 for random.
#                                     Default: -1.
# $queue_buffering_max_messages     - Maximum number of messages allowed on the
#                                     local Kafka producer queue.  Default: 1000000
# $message_send_max_retries         - Maximum number of retries per messageset.
#                                     Default: 3
# $topic_request_required_acks      - Required ack level.  Default: 1
# $topic_message_timeout_ms         - Local message timeout (milliseconds).
#                                     Default: 60000
# $varnish_opts                     - Arbitrary hash of varnish CLI options.
#                                     Default: { 'm' => 'RxRequest:^(?!PURGE$)' }
# $log_data_copy                    - If true, log tag data read from VSL files
#                                     should be copied instantly when read.  Default true.
# $log_level                        - varnishkafka log level.  Default 6 (info).
# $log_stderr                       - Boolean.  Whether to log to stderr.  Default: true
# $log_syslog                       - Boolean.  Whether to log to syslog.  Default: true
#
# $conf_template
# $default_template
#
class varnishkafka(
    $brokers                        = $varnishkafka::defaults::brokers,
    $topic                          = $varnishkafka::defaults::topic,
    $sequence_number                = $varnishkafka::defaults::sequence_number,

    $output                         = $varnishkafka::defaults::output,
    $format_type                    = $varnishkafka::defaults::format_type,
    $format                         = $varnishkafka::defaults::format,

    $format_key_type                = $varnishkafka::defaults::format_key_type,
    $format_key                     = $varnishkafka::defaults::format_key,

    $partition                      = $varnishkafka::defaults::partition,
    $queue_buffering_max_messages   = $varnishkafka::defaults::queue_buffering_max_messages,
    $message_send_max_retries       = $varnishkafka::defaults::message_send_max_retries,
    $topic_request_required_acks    = $varnishkafka::defaults::topic_request_required_acks,
    $topic_message_timeout_ms       = $varnishkafka::defaults::topic_message_timeout_ms,

    $varnish_opts                   = $varnishkafka::defaults::varnish_opts,
    $log_data_copy                  = $varnishkafka::defaults::log_data_copy,

    $log_level                      = $varnishkafka::defaults::log_level,
    $log_stderr                     = $varnishkafka::defaults::log_stderr,
    $log_syslog                     = $varnishkafka::defaults::log_syslog,

    $daemon_opts                    = $varnishkafka::defaults::daemon_opts,

    $conf_template                  = $varnishkafka::defaults::conf_template,
    $default_template               = $varnishkafka::defaults::default_template
) inherits varnishkafka::defaults
{
    package { 'varnishkafka':
        ensure => 'present',
    }

    file { '/etc/varnishkafka.conf':
        content => template($conf_template),
        require => Package['varnishkafka'],
    }

    file { '/etc/default/varnishkafka':
        content => template($default_template),
        require => Package['varnishkafka'],
    }

    service { 'varnishkafka':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => [File['/etc/varnishkafka.conf'], File['/etc/default/varnishkafka']],
    }
}