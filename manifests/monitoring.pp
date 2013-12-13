# == Class varnishkafka::monitoring
# Installs varnishkafka python ganglia module.
#
class varnishkafka::monitoring(
    $ensure = 'present'
)
{
    Class['varnishkafka'] -> Class['varnishkafka::monitoring']

    $log_statistics_file     = $::varnishkafka::log_statistics_file
    $log_statistics_interval = $::varnishkafka::log_statistics_interval
    file { '/usr/lib/ganglia/python_modules/varnishkafka.py':
        source  => 'puppet:///modules/varnishkafka/varnishkafka_ganglia.py',
        require => Package['ganglia-monitor-python'],
        notify  => Service['gmond'],
    }

    # Metrics reported by varnishkafka_ganglia.py are
    # not known until the varnishkafka.stats.json file is
    # parsed.  Run it with the --generate-pyconf option to
    # generate the .pyconf file now.
    exec { 'generate-varnishkafka.pyconf':
        require => File['/usr/lib/ganglia/python_modules/varnishkafka.py'],
        command => "/usr/bin/python /usr/lib/ganglia/python_modules/varnishkafka.py --generate --tmax=${log_statistics_interval} ${log_statistics_file}> /etc/ganglia/conf.d/varnishkafka.pyconf.new",
    }

    exec { 'replace-varnishkafka.pyconf':
        cwd     => '/etc/ganglia/conf.d',
        path    => '/bin:/usr/bin',
        unless  => 'diff -q varnishkafka.pyconf.new varnishkafka.pyconf && rm varnishkafka.pyconf.new',
        command => 'mv varnishkafka.pyconf.new varnishkafka.pyconf',
        notify  => Service['gmond'],
    }
}
