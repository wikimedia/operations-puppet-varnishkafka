# == Class varnishkafka::defaults
#
class varnishkafka::defaults {
    $brokers                        = ['localhost:9092']
    $topic                          = 'varnish'
    $sequence_number                = 0

    $output                         = 'kafka'
    $format_type                    = 'string'
    $format                         = '%l	%n	%t	%{Varnish:time_firstbyte}x	%h	%{Varnish:handling}x/%s	%b	%m	http://%{Host}i%U%q	-	%{Content-Type}o	%{Referer}i	%{X-Forwarded-For}i	%{User-agent!escape}i'

    $format_key_type                = 'kafka'
    $format_key                     = undef

    $partition                      = -1
    $queue_buffering_max_messages   = 1000000
    $message_send_max_retries       = 3
    $topic_request_required_acks    = 1
    $topic_message_timeout_ms       = 60000

    $varnish_opts                   = {
        'm' => 'RxRequest:^(?!PURGE$)',
    }
    $log_data_copy                  = true

    $log_level                      = 6
    $log_stderr                     = true
    $log_syslog                     = true

    $daemon_opts                    = undef

    $conf_template                  = 'varnishkafka/varnishkafka.conf.erb'
    $default_template               = 'varnishkafka/varnishkafka.default.erb'
}
