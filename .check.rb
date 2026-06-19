#!/usr/bin/env ruby

require "yaml"

# please add or remove files on the top dir for management if necessary.
# note that files in subdirectories are not included in the scan.
PROJECT_FILES = %w[
  .check.rb
  .editorconfig
  .gitattributes
  .gitignore
  .pre-commit-config.yaml
  .travis.yml
  CONTRIBUTING.md
  Gemfile
  Gemfile.lock
  Makefile
  Rakefile
  README.md
].freeze

$PROGRAM_NAME = File.basename($PROGRAM_NAME)

def run_and_split_nul(cmd)
  IO.popen(cmd, "rb") { |pipe| pipe.read.split("\0") }
end

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

Dir.chdir(__dir__)

entries = run_and_split_nul(%w[git ls-files -z :^*/*])

print "checking project management files\n"
unless (PROJECT_FILES - entries).empty?
  errinfo.push <<~MESG
    missing files: #{(PROJECT_FILES - entries).join(" ")}
    > if you removed project management files, edit PROJECT_FILES in #{$PROGRAM_NAME} file.
  MESG
end

(entries - PROJECT_FILES).each do |f|
  print "checking #{f}\n"

  unless f.match?(/\.gem$/)
    errinfo.push <<~MESG
      #{f}: not a ".gem" file
      > if you added files for mruby gem (mgem), the file extension should be changed to ".gem".
      > if you added files for project management, add into PROJECT_FILES of #{$PROGRAM_NAME} file.
    MESG
    next
  end

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
