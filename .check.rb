#!/usr/bin/env ruby

require 'yaml'

Dir.glob("#{File.dirname __FILE__}/*.gem") do |f|
  print "checking #{f}\n"
  YAML.parse File.read f
end

print "gem files check OK\n"
