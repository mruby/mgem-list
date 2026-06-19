#!/usr/bin/env ruby

require "yaml"

errinfo = Object.new
class << errinfo
  def push(mesg)
    @errors ||= []
    @errors << mesg.to_s.sub(/\n+\z/, "")
  end

  def empty?
    !@errors || @errors.empty?
  end

  def size
    @errors&.size || 0
  end

  def output
    warn <<~ERR

      #{@errors&.join("\n")}
      #{size} error(s) generated.
    ERR
  end
end

Dir.glob("#{File.dirname __FILE__}/*.gem") do |f|
  print "checking #{f}\n"
  tree = YAML.parse_file(f).transform
  %w[name description author website repository protocol license].each do |key|
    errinfo.push "#{f}: no #{key}" unless tree[key]
  end
  errinfo.push "#{f}: invalid protocol" unless ["git"].include? tree["protocol"] # TODO

  tree["dependencies"].to_a.each do |x|
    errinfo.push "#{f}: invalid dependencies" unless x.is_a?(String)
  end
rescue StandardError => e
  errinfo.push e
end

unless errinfo.empty?
  errinfo.output
  exit 1
end

print "gem files check OK\n"
