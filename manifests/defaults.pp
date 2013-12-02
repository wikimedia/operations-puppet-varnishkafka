# == Class varnishkafka::defaults
#
class varnishkafka::defaults {
    $brokers                        = ['localhost:9092']
    $topic                          = 'varnish'
    $sequence_number                = 0

    $output                         = 'kafka'
    $format_type                    = 'string'
    $format                         = '%l	%n	%t	%{Varnish:time_firstbyte}x	%h	%{Varnish:handling}x/%s	%b	%m	http://%{Host}i%U%q	-	%{Content-Type}o	%{Referer}i	%{X-Forwarded-For}i	%{User-agent!escape}i	%{Accept-Language}i'

    $format_key_type                = 'string'
    $format_key                     = undef

    $partition                      = -1
    $queue_buffering_max_messages   = 100000
    $message_send_max_retries       = 3
    $topic_request_required_acks    = 1
    $topic_message_timeout_ms       = 300000
    $topic_request_timeout_ms       = 5000
    $compression_codec              = 'none'

    $varnish_opts                   = {
        'm' => 'RxRequest:^(?!PURGE$)',
    }

    $tag_size_max                   = 2048
    $logline_line_scratch_size      = 4096
    $logline_hash_size              = 5000
    $logline_hash_max               = 5
    $logline_data_copy              = true

    $log_level                      = 6
    $log_stderr                     = false
    $log_syslog                     = true
    $log_statistics_file            = '/var/cache/varnishkafka/varnishkafka.stats.json'
    $log_statistics_interval        = 60

    $conf_template                  = 'varnishkafka/varnishkafka.conf.erb'
    $default_template               = 'varnishkafka/varnishkafka.default.erb'
}
