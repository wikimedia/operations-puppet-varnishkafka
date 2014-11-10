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
#                                     Default: -1
# $queue_buffering_max_messages     - Maximum number of messages allowed on the
#                                     local Kafka producer queue.  Default: 100000
# $queue_buffering_max_ms           - Maximum time, in milliseconds, for buffering
#                                     data on the producer queue.  Default: 1000
# $batch_num_messages               - Maximum number of messages batched in one MessageSet.
#                                     Default: 1000
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
# $varnish_name                     - Name of varnish instance to log from.  Default: undef
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
# $should_subscribe                 - If true, the varnishkafka service will restart for config
#                                     changes.  Default: true.
# $conf_template
#
define varnishkafka::instance(
    $brokers                        = ['localhost:9092'],
    $topic                          = 'varnish',
    $sequence_number                = 0,
    $output                         = 'kafka',
    $format_type                    = 'string',
    $format                         = '%l	%n	%t	%{Varnish:time_firstbyte}x	%h	%{Varnish:handling}x/%s	%b	%m	http://%{Host}i%U%q	-	%{Content-Type}o	%{Referer}i	%{X-Forwarded-For}i	%{User-agent!escape}i	%{Accept-Language}i',
    $format_key_type                = 'string',
    $format_key                     = undef,

    $partition                      = -1,
    $queue_buffering_max_messages   = 100000,
    $queue_buffering_max_ms         = 1000,
    $batch_num_messages             = 1000,
    $message_send_max_retries       = 3,
    $topic_request_required_acks    = 1,
    $topic_message_timeout_ms       = 300000,
    $topic_request_timeout_ms       = 5000,
    $socket_send_buffer_bytes       = 0,
    $compression_codec              = 'none',

    $varnish_name                   = undef,
    $varnish_opts                   = { 'm' => 'RxRequest:^(?!PURGE$)', },

    $tag_size_max                   = 2048,
    $logline_scratch_size           = 4096,
    $logline_hash_size              = 5000,
    $logline_hash_max               = 5,
    $logline_data_copy              = true,

    $log_level                      = 6,
    $log_stderr                     = false,
    $log_syslog                     = true,
    $log_statistics_file            = "/var/cache/varnishkafka/${name}.stats.json",
    $log_statistics_interval        = 60,

    $should_subscribe               = true,
    $conf_template                  = 'varnishkafka/varnishkafka.conf.erb',
) {
    require ::varnishkafka

    file { "/etc/varnishkafka/${name}.conf":
        content => template($conf_template),
        require => Package['varnishkafka'],
    }

    file { "/etc/init/varnishkafka-${name}.conf":
        content => template('varnishkafka/varnishkafka.upstart.conf.erb'),
        require => Package['varnishkafka'],
    }

    service { "varnishkafka-${name}":
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
    }

    # subscribe varnishkafka to its config files
    if $should_subscribe {
        File["/etc/varnishkafka/${name}.conf"] ~> Service["varnishkafka-${name}"]
    }
    # else just require them
    else {
        File["/etc/varnishkafka/${name}.conf"] -> Service["varnishkafka-${name}"]
    }
}
