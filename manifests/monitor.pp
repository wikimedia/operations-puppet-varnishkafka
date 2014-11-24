# == Define varnishkafka::monitor
# Installs varnishkafka python ganglia module.
#
define varnishkafka::monitor(
    $log_statistics_file     = "/var/cache/varnishkafka/${name}.stats.json",
    $pyconf_file             = "/etc/ganglia/conf.d/varnishkafka-${name}.pyconf",
    $log_statistics_interval = 60,
    $key_prefix              = $name,
) {
    require ::varnishkafka

    Varnishkafka::Instance[$name] -> Varnishkafka::Monitor[$name]

    $varnishkafka_py = "/usr/lib/ganglia/python_modules/varnishkafka.py"
    $generate_pyconf_command = "/usr/bin/python ${varnishkafka_py} --generate-pyconf ${pyconf_file} --key-prefix=${key_prefix} --tmax=${log_statistics_interval} ${log_statistics_file}"

    if ! defined(File[$varnishkafka_py]) {
        file { $varnishkafka_py:
            source  => 'puppet:///modules/varnishkafka/varnishkafka_ganglia.py',
            require => Package['ganglia-monitor'],
            notify  => Service['gmond'],
        }
    }

    exec { "generate_varnishkafka_${name}_gmond_pyconf":
        command => $generate_pyconf_command,
        onlyif  => "${generate_pyconf_command} --dry-run",
        require => File[$varnishkafka_py],
        notify  => Service['gmond'],
    }
}
