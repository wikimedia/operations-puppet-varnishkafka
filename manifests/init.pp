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
#                                     local Kafka producer queue.  Default: 100000
# $message_send_max_retries         - Maximum number of retries per messageset.
#                                     Default: 3
# $topic_request_required_acks      - Required ack level.  Default: 1
# $topic_message_timeout_ms         - Local message timeout (milliseconds).
#                                     Default: 300000
# $topic_request_timeout_ms         - Ack timeout of the produce request.
#                                     Default: 5000
# $socket_send_buffer_bytes         - SO_SNDBUFF Socket send buffer size. System default is used if 0.
#                                     Default: 0
# $compression_codec                - Compression codec to use when sending batched messages to
#                                     Kafka.  Valid values are 'none', 'gzip', and 'snappy'.
#                                     Default: none
# $varnish_opts                     - Arbitrary hash of varnish CLI options.
#                                     Default: { 'm' => 'RxRequest:^(?!PURGE$)' }
# $tag_size_max                     - Maximum size of an individual field.  Field will be truncated
#                                     if it is larger than this.  Default: 2048
# $logline_line_scratch_size        - Size of static log line buffer.  If a line is larger than
#                                     this buffer, temp buffers will be allocated.  Set this
#                                     slighly larger than your expected line size.
#                                     Default: 4096
# $logline_hash_size                - Number of hash buckets.  Set this to avg_requests_per_second / 5.
#                                     Default: 5000
# $logline_hash_max                 - Max number of log lines / bucket.  Set this to
#                                     avg_requests_per_second / $log_hash_size.
#                                     Default: 5
# $logline_data_copy                - If true, log tag data read from VSL files
#                                     should be copied instantly when read.  Default true.
# $log_level                        - varnishkafka log level.  Default 6 (info).
# $log_stderr                       - Boolean.  Whether to log to stderr.  Default: true
# $log_syslog                       - Boolean.  Whether to log to syslog.  Default: true
# $log_statistics_file              - Path to varnishkafka JSON statistics file.
#                                     Default: /var/cache/varnishkafka/varnishkafka.stats.json
# $log_statistics_interval          - JSON statistics file output interval in seconds.  Default: 60
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
    $topic_request_timeout_ms       = $varnishkafka::defaults::topic_request_timeout_ms,
    $socket_send_buffer_bytes       = $varnishkafka::defaults::socket_send_buffer_bytes,
    $compression_codec              = $varnishkafka::defaults::compression_codec,

    $varnish_opts                   = $varnishkafka::defaults::varnish_opts,
    $tag_size_max                   = $varnishkafka::defaults::tag_size_max,
    $logline_line_scratch_size      = $varnishkafka::defaults::logline_line_scratch_size,
    $logline_hash_size              = $varnishkafka::defaults::logline_hash_size,
    $logline_hash_max               = $varnishkafka::defaults::logline_hash_max,
    $logline_data_copy              = $varnishkafka::defaults::logline_data_copy,

    $log_level                      = $varnishkafka::defaults::log_level,
    $log_stderr                     = $varnishkafka::defaults::log_stderr,
    $log_syslog                     = $varnishkafka::defaults::log_syslog,
    $log_statistics_file            = $varnishkafka::defaults::log_statistics_file,
    $log_statistics_interval        = $varnishkafka::defaults::log_statistics_interval,

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