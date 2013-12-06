###  VarnishkafkaLogster is a subclass of JsonLogster.
###  It is meant to parse varnishkafka
###  (https://github.com/wikimedia/operations-software-varnish-varnishkafka)
###  JSON statistics.
###
###  Example:
###  sudo ./logster --dry-run --output=ganglia VarnishkafkaLogster /var/cache/varnishkafka.stats.json
###

from logster.parsers.JsonLogster import JsonLogster

class VarnishkafkaLogster(JsonLogster):
    def key_filter(self, key):

        # metric keys to skip.
        skip = [
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

        if key in skip:
            return False
        # prepend appropriate rdkafka or varnishkafka to the key,
        # depdending on where the metric has come from.
        elif key == 'varnishkafka':
            key = 'kafka%svarnishkafka' % self.key_separator
        elif key == 'kafka':
            key = 'kafka%srdkafka' % self.key_separator
        # don't send any bootstrap rdkafka metrics
        elif 'bootstrap' in key:
            return False
        # any key separators in the key with '-'
        elif self.key_separator in key:
            # this won't do anything if key_separator is '-'
            key = key.replace(self.key_separator, '-')
        # don't send anything that starts with -
        elif key.startswith('-'):
            return False

        return key
