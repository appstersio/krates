require 'securerandom'

ENV['RACK_ENV'] = 'test'
ENV['VAULT_KEY'] = SecureRandom.base64(64)
ENV['VAULT_IV'] = SecureRandom.base64(64)
ENV['ACME_ENDPOINT'] = 'https://acme-staging.api.letsencrypt.org/'
require 'dotenv'
Dotenv.load

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/app/initializers/'
    add_group 'Models', 'app/models'
    add_group 'Mutations', 'app/mutations'
    add_group 'Api', 'app/routes'
    add_group 'Helpers', 'app/helpers'
    add_group 'Services', 'app/services'
    add_group 'Workers', 'app/workers'
  end
end

require_relative '../lib/thread_tracer'
#require_relative '../lib/moped_session_tracer'

# abort on Moped::Session threading issues
ThreadTracer.fatal!

require 'webmock/rspec'
require_relative '../app/boot'
require_relative '../server'
require 'rack/test'
require 'mongoid-rspec'
require 'pry'

require_relative '../app/services/mongodb/migrator'

Celluloid.logger = nil
Logging.initialize_logger((ENV['LOG_TARGET'] || '/dev/null'), (ENV['LOG_LEVEL'] || Logger::UNKNOWN).to_i)

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  if ENV['CI']
    config.filter_run_excluding :performance => true
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include Rack::Test::Methods

  def app
    Server
  end

  config.before(:suite) do
    MongoPubsub.start!(PubsubChannel)
    sleep 0.1 until Mongoid.default_client.database.collection_names.include?(PubsubChannel.collection.name)
    Mongoid::Tasks::Database.create_indexes if ENV["CI"]
  end

  config.before(:each) do
    MongoPubsub.clear!
  end

  config.after(:each) do
    Mongoid.default_client.database.collections.each do |collection|
      unless collection.name.include?('system.')
        collection.find.delete_many unless collection.capped?
      end
    end
  end

  # TODO: Figure out if we need to enforce timeouts around each test
  # config.around :each do |ex|
  #   Timeout.timeout(5.0) do
  #     ex.run
  #   end
  # end

  config.around :each, celluloid: true do |ex|
    Celluloid.boot
    ex.run
    Celluloid.actor_system.group.group.each { |t| t.kill if t.role == :future }
    Celluloid.shutdown
  end

  config.around :each, eventmachine: true do |example|
    EM.run {
      example.run
      EM.stop
    }
  end


  def response
    last_response
  end

  def json_response
    @json_response ||= JSON.parse(response.body)
  end

  def fixture_dir(dir)
    "./spec/fixtures/#{dir}/"
  end

  def from_fixture(path)
    File.read "./spec/fixtures/#{path}"
  end

  RSpec::Matchers.define_negated_matcher :not_change, :change
end

require_glob __dir__ + '/support/*.rb'
