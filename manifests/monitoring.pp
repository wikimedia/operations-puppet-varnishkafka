# == Class varnishkafka::monitoring
# Uses logster (https://github.com/wikimedia/operations-debs-logster)
# to tail varnishkafka.stats.json file send stats to Ganglia.
#
# TODO: Support more than logster ganglia output via
# class parameters.
class varnishkafka::monitoring(
    $ensure = 'present'
)
{
    Class['varnishkafka'] -> Class['varnishkafka::monitoring']

    # varnishkafka monitoring is done via the logster package.
    package { 'logster':
        ensure => 'installed',
        # don't bother doing this unless ganglia is installed
        require => Package['ganglia-monitor']
    }
    # put the VarnishkafkaLogster.py module in place
    if !defined(File['/usr/local/share/logster']) {
        file { '/usr/local/share/logster':
            ensure => 'directory',
        }
    }

    # Custom JsonLogster parser subclass to filter and transform
    # a few varnishkafka stats JSON keys.
    file { '/usr/local/share/logster/VarnishkafkaLogster.py':
        source  => 'puppet:///modules/varnishkafka/VarnishkafkaLogster.py',
        require => File['/usr/local/share/logster'],
    }

    # Run logster using the VarnishkafkaLogster parser and send updated stats to Ganglia.
    $cron_command = "export PYTHONPATH=\$PYTHONPATH:/usr/local/share/logster && /usr/bin/logster --output ganglia --gmetric-options='--group=kafka --tmax=60' VarnishkafkaLogster.VarnishkafkaLogster ${varnishkafka::log_statistics_file}"
    cron { 'varnishkafka-stats-to-ganglia':
        ensure  => $ensure,
        command => $cron_command,
        minute  => '*/1',
        require => [Package['logster'], File['/usr/local/share/logster/VarnishkafkaLogster.py']]
    }
}
