#!/bin/ruby
# highline/import conflicts with github_api
require 'highline'
require 'github_api'
require 'tmpdir'

USER = 'dbresson'
REPO = 'twitch'

login = HighLine.new.ask "Github Login: "
password = HighLine.new.ask("Github Password: ") {|q| q.echo = false }

client = Github.new basic_auth: "#{login}:#{password}"

pr = client.pull_requests.get user: USER, repo: REPO, number: ARGV[0]

if pr.merged
  STDERR.puts "PR already merged"
  exit 1
elsif pr.mergeable == nil
  STDERR.puts "PR merge not available, try again later"
  exit 2
elsif !pr.mergeable
  STDERR.puts "PR not mergeable, address conflicts and try again"
  exit 3
end

Dir.mktmpdir do |dir|
  old_pwd = Dir.pwd

  begin
    Dir.chdir dir
    if !system("git clone #{pr.repo.ssh_url}")
      STDERR.puts "Failed cloning the repo"
      exit 4
    end

    Dir.chdir pr.repo.name
    if !system("git checkout #{pr.merge_commit_sha}")
      STDERR.puts "Failed to checkout merge commit"
      exit 5
    end

    %w{lint test build}.each do |cmd|
      result = system("make #{cmd}")
      result_message = "#{cmd} status: #{ result ? 'SUCCESS' : 'FAILED'}"
      client.issues.comments.create user: USER, repo: REPO, number: pr.id, body: result_msg
    end

  ensure
    Dir.chdir old_pwd
  end
end
