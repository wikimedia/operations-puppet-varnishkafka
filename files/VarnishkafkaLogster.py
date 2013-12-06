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

        if key == 'varnishkafka':
            key = 'kafka%svarnishkafka' % self.key_separator
        elif key == 'kafka':
            key = 'kafka%srdkafka' % self.key_separator
        elif 'bootstrap' in key:
            return False
        elif self.key_separator in key:
            # this won't do anything if key_separator is '-'
            key = key.replace(self.key_separator, '-')
        elif key.startswith('-'):
            return False
        elif key in ['name', 'topic', 'toppars', 'time', 'fetch_state', 'ts']:
            return False

        return key
