#!/usr/bin/env ruby

require "optparse"
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

class Array # rubocop:disable Style/Documentation
  def extract_git_branches
    grep(%r{^refs/heads/}).map { |e| e.delete_prefix("refs/heads/") }
  end
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

def git_get_remote_refs(repository)
  env = { "GIT_TERMINAL_PROMPT" => "0" }
  cmd = %W[git ls-remote -btq --refs #{repository}]

  IO.popen(env, cmd, "r", err: File::NULL) do |r|
    refs = r.read.split(/[\n\t]/).select.with_index { |_, i| i.odd? }
    return refs unless refs.empty?
  end

  nil
end

def check_git_repository(gemname, tree, errinfo) # rubocop:disable Metrics/MethodLength
  repo = tree["repository"].to_s
  branch = tree["branch"] || "master"
  refs = git_get_remote_refs(repo) unless repo.empty?

  if refs.nil?
    errinfo.push <<~INFO
      #{gemname}: unable to access the repository or locate a valid branch name.
    INFO
  elsif refs.include?("refs/heads/#{branch}")
    # OK
  elsif refs.include?("refs/tags/#{branch}")
    errinfo.push <<~INFO
      #{gemname}: instead of branches, the tag "#{branch}" is used.
    INFO
  else
    errinfo.push <<~INFO
      #{gemname}: branch "#{branch}" is missing.
      > candidates: #{refs.extract_git_branches.join(" ")}
    INFO
  end
end

Dir.chdir(__dir__)

banner = <<~BANNER
  Usage: #{$PROGRAM_NAME} [options]
BANNER

gitrepo = false
interval = 1.2
OptionParser.new(banner, 24, "") do |o|
  o.separator ""

  o.on "--gitrepo", "Verify a Git repository and a specified branch" do
    gitrepo = true
  end

  o.on "--interval seconds", "Specify the access interval with `--gitrepo` (default: #{interval})", Float do |n|
    interval = n
  end

  o.order!
end

entries = run_and_split_nul(%w[git ls-files -z :^*/*])

puts "checking project management files"
unless (PROJECT_FILES - entries).empty?
  errinfo.push <<~MESG
    missing files: #{(PROJECT_FILES - entries).join(" ")}
    > if you removed project management files, edit PROJECT_FILES in #{$PROGRAM_NAME} file.
  MESG
end

(entries - PROJECT_FILES).each_with_index do |f, i|
  puts "checking #{f}"

  unless f.match?(/\.gem$/)
    errinfo.push <<~MESG
      #{f}: not a ".gem" file
      > if you added files for mruby gem (mgem), the file extension should be changed to ".gem".
      > if you added files for project management, add into PROJECT_FILES of #{$PROGRAM_NAME} file.
    MESG
    next
  end

  tree = YAML.load_file(f)
  %w[name description author website repository protocol license].each do |key|
    errinfo.push "#{f}: no #{key}" unless tree[key]
  end
  errinfo.push "#{f}: invalid protocol" unless ["git"].include? tree["protocol"] # TODO

  tree["dependencies"].to_a.each do |x|
    errinfo.push "#{f}: invalid dependencies" unless x.is_a?(String)
  end

  if gitrepo
    sleep interval if i.positive?
    check_git_repository(f, tree, errinfo)
  end
rescue StandardError => e
  errinfo.push e
end

unless errinfo.empty?
  errinfo.output
  exit 1
end

puts "gem files check OK"
