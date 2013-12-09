###  VarnishkafkaLogster is a subclass of JsonLogster.
###  It is meant to parse varnishkafka
###  (https://github.com/wikimedia/operations-software-varnish-varnishkafka)
###  JSON statistics.
###
###  Example:
###  sudo ./logster --dry-run --output=ganglia VarnishkafkaLogster /var/cache/varnishkafka.stats.json
###

from logster.parsers.JsonLogster import JsonLogster
from logster.logster_helper import MetricObject

class VarnishkafkaLogster(JsonLogster):
    # Default ganglia slope is 'both', aka GAUGE.
    # These keys should be given a slope of
    # 'positive' aka COUNTER.
    counter_metrics = [
        'tx',
        'txbytes',
        'txerrs',
        'txmsgs',

        'rx',
        'rxbytes'
        'rxerrs',

        'kafka_drerr',
        'scratch_toosmall',
        'txerr',
        'trunc',
        'scratch_tmpbufs',
    ]

    # metric keys to skip.
    skip_metrics = [
        'app_offset',
        'commited offset',
        'desired',
        'eof_offset',
        'fetch_state',
        'fetchq_cnt',
        'fetchq_cnt',
        'leader',
        'lp_curr'
        'name',
        'next_offset',
        'nodeid',
        'partition',
        'query_offset',
        'seq',
        'time',
        'topic',
        'toppars',
        'ts',
        'unknown',
    ]

    def get_metric_object(self, metric_name, metric_value):
        '''
        Overrides JsonLogster's get_metric_object() method to
        manually set slope to positive for counter metrics.
        '''

        metric_object = JsonLogster.get_metric_object(self, metric_name, metric_value)

        metric_slope = ''

        if metric_name.split(self.key_separator)[-1] in VarnishkafkaLogster.counter_metrics:
            metric_slope = 'positive'

        metric_object.slope = metric_slope
        return metric_object

    def key_filter(self, key):
        '''
        Overrides JsonLogster's key_filter method to
        filter out irrelevant metrics, and to transform
        the keys of some to make them more readable.
        '''

        if key in VarnishkafkaLogster.skip_metrics:
            return False
        # prepend appropriate rdkafka or varnishkafka to the key,
        # depdending on where the metric has come from.
        elif key == 'varnishkafka':
            key = 'kafka{0}varnishkafka'.format(self.key_separator)
        elif key == 'kafka':
            key = 'kafka{0}rdkafka'.format(self.key_separator)
        # don't send any bootstrap rdkafka metrics
        elif 'bootstrap' in key:
            return False
        # replace any key separators in the key with '-'
        elif self.key_separator in key:
            # this won't do anything if key_separator is '-'
            key = key.replace(self.key_separator, '-')
        # don't send anything that starts with -
        elif key.startswith('-'):
            return False

        return key
