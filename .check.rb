#!/usr/bin/env ruby

require 'yaml'

Dir.glob("#{File.dirname __FILE__}/*.gem") do |f|
  print "checking #{f}\n"
  tree = YAML.parse_file(f).transform
  unless tree['name'] && tree['description'] && tree['author'] && tree['website'] && tree['repository']
    raise 'invalid YAML'
  end
  raise 'invalid protocol' unless ['git'].include? tree['protocol'] # TODO
  raise 'no license' unless tree['license']

  tree['dependencies'].to_a.each do |x|
    raise 'invalid dependencies' unless x.is_a?(String)
  end
end

print "gem files check OK\n"
