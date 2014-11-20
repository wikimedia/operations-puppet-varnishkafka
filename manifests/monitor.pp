# == Define varnishkafka::monitor
# Installs varnishkafka python ganglia module.
#
define varnishkafka::monitor(
    $log_statistics_file     = "/var/cache/varnishkafka/${name}.stats.json",
    $log_statistics_interval = 60,
    $key_prefix              = $name,
) {
    require ::varnishkafka

    Varnishkafka::Instance[$name] -> Varnishkafka::Monitor[$name]

    if ! defined(File['/usr/lib/ganglia/python_modules/varnishkafka.py']) {
        file { '/usr/lib/ganglia/python_modules/varnishkafka.py':
            source  => 'puppet:///modules/varnishkafka/varnishkafka_ganglia.py',
            require => Package['ganglia-monitor'],
            notify  => Service['gmond'],
        }
    }

    # Metrics reported by varnishkafka_ganglia.py are
    # not known until the varnishkafka.stats.json file is
    # parsed.  Run it with the --generate-pyconf option to
    # generate the .pyconf file now.
    exec { "generate-varnishkafka-${name}.pyconf":
        require => File['/usr/lib/ganglia/python_modules/varnishkafka.py'],
        command => "/usr/bin/python /usr/lib/ganglia/python_modules/varnishkafka.py --generate --key-prefix='${key_prefix}' --tmax=${log_statistics_interval} ${log_statistics_file} > /etc/ganglia/conf.d/varnishkafka-${name}.pyconf.new",
        onlyif  => "/usr/bin/test -s ${log_statistics_file}",
        before  => Exec["replace-varnishkafka-${name}.pyconf"],
    }

    exec { "replace-varnishkafka-${name}.pyconf":
        cwd         => '/etc/ganglia/conf.d',
        path        => '/bin:/usr/bin',
        unless      => "diff -q varnishkafka-${name}.pyconf.new varnishkafka-${name}.pyconf && rm varnishkafka-${name}.pyconf.new",
        command     => "mv varnishkafka-${name}.pyconf.new varnishkafka-${name}.pyconf || true",
        require     => Exec["generate-varnishkafka-${name}.pyconf"],
        notify      => Service['gmond'],
    }
}
