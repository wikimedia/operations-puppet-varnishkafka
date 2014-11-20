# == Class varnishkafka
# Configures and runs varnishkafka Varnish to Kafka producer.
# See: https://github.com/wikimedia/varnishkafka
#
class varnishkafka {
    package { 'varnishkafka':
        ensure => present,
    }

    file { '/etc/varnishkafka':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        recurse => true,
        purge   => true,
        force   => true,
    }

    # Don't use the init script provided by the package, because it precludes
    # running multiple instances.

    file { '/var/cache/varnishkafka':
        ensure  => directory,
        owner   => 'varnishlog',
        group   => 'varnishlog',
        mode    => '0755',
        require => Package['varnishkafka'],
    }

    # Install a logrotate file that will work with multiple varnishkafka instances
    file { '/etc/logrotate.d/varnishkafka':
        source  => 'puppet:///modules/varnishkafka/varnishkafka_logrotate',
    }

    # Managing the varnishkafka service via its init script requires that the
    # init script be present and that the default file mark the service as
    # enabled. Invoking start-stop-daemon directly allows us to manage the
    # service without having a tricky ordering dependency on those two
    # resources.

    exec { 'stop-varnishkafka-service':
        command   => '/sbin/start-stop-daemon --stop --pidfile /var/run/varnishkafka/varnishkafka.pid --exec /usr/bin/varnishkafka',
        onlyif    => '/sbin/start-stop-daemon --status --pidfile /var/run/varnishkafka/varnishkafka.pid --exec /usr/bin/varnishkafka',
        subscribe => Package['varnishkafka'],
    }

    file { '/etc/init.d/varnishkafka':
        ensure    => absent,
        subscribe => Package['varnishkafka'],
    }

    file { '/etc/default/varnishkafka':
        ensure    => absent,
        subscribe => Package['varnishkafka'],
    }
}
