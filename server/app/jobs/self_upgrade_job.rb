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
    # Very basic, just stop Puma process via pumactl for now
    info "Triggering forced upgrade of the current version as been instructed, initiating Puma server shutdown via 'pumactl'..."
    # TODO: Fix issue with shutdown sequence when MongoPubSub notifications not delivered, since the actor is already terminated.
    system("pumactl stop --pidfile /var/tmp/server.pid")
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