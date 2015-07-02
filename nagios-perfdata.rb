#!/usr/local/rvm/wrappers/default/ruby
#
# Nagios performance data to Graphite plain text mutator extension.
# ===
#
# Copyright 2013 Heavy Water Operations, LLC.
#
# Modified Hayden Ball 2015
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
require 'json'

event = JSON.parse(STDIN.read, :symbolize_names => true)


result = []
client = event[:client]
check  = event[:check]

# https://www.nagios-plugins.org/doc/guidelines.html#AEN200
perfdata = check[:output].split('|').last.strip

perfdata.split(/\s+/).each do |data|
  # label=value[UOM];[warn];[crit];[min];[max]
  label, value = data.split('=')

  name = label.strip.gsub(/\W/, '_')
  measurement = value.strip.split(';').first.gsub(/[^-\d\.]/, '')

  path = [client[:name], check[:name], name].join('.')

  result << [path, measurement, check[:executed]].join("\t")
end

check[:output] = result.join("\n") + "\n"
event[:check] = check

puts event.to_json
