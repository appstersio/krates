require 'octokit'
require_relative '../services/logging'

class SelfUpgradeJob
  include Celluloid
  include Logging

  attr_reader :client

  def initialize(launch = true)
    info "Initializing self-upgrade job to keep it up-to-date."
    @client = Octokit::Client.new()
    async.perform if launch
  end

  def perform
    info "starting to watch newer version(s) to upgrade to in #{Thread.current}"
    loop do
      sleep 10.minutes
      poll_upgrade
    end
  end

  def poll_upgrade
    lv, cv = latest_version, current_version
    if lv > cv
      info "Latest version '#{lv}' vs. '#{cv}' is available, initiating an upgrade."
      shutdown
    end
    info "Current version '#{cv}' is good as-is, no need to upgrade since the latest version is '#{lv}'."
  end

private

  def shutdown
    # Very basic, just terminate the process for now
    info "Terminating current process as been instructed by upgrade routine."
    exit(0)
  end

  def latest_version
    # Filter out pre-release items, since they aren't ready yet for production
    lr = client.releases('appstersio/krates').filter {|o| o.prerelease == false}
    lv = lr.map(&:tag_name).first
    Gem::Version.create(lv.delete('v'))
  end

  def current_version
    Gem::Version.create(Server::VERSION)
  end
end