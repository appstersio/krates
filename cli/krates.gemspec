# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kontena/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "krates"
  spec.version       = Kontena::Cli::VERSION
  spec.authors       = ["Pavel Tsurbeleu"]
  spec.email         = ["staticpagesio@gmail.com"]
  spec.summary       = %q{Krates command line tool}
  spec.description   = %q{Command-line client for the Krates container and microservices platform}
  spec.homepage      = "https://krates.appsters.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|examples|tasks)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|examples|tasks)/})
  spec.require_paths = ["lib"]

  # NOTE: Exclude files not relevant to the plugin
  spec.files        -= %w[ Dockerfile Makefile docker-compose.yml .dockerignore Rakefile .gitignore .rspec ]
  spec.files        -= %w[ Gemfile krates.gemspec README.md ]

  spec.required_ruby_version = ">= 2.3.0"

  # TODO: Restore metadata section back

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_runtime_dependency "excon", "0.62.0"
  spec.add_runtime_dependency "tty-prompt", "0.16.1"
  spec.add_runtime_dependency "clamp", "~> 1.2"
  spec.add_runtime_dependency "ruby_dig", "~> 0.0.2"
  spec.add_runtime_dependency "hash_validator", "0.8.0"
  spec.add_runtime_dependency "retriable", "~> 2.1"
  spec.add_runtime_dependency "opto", "1.8.7"
  spec.add_runtime_dependency "semantic", "~> 1.5"
  spec.add_runtime_dependency "liquid", "~> 4.0"
  spec.add_runtime_dependency "tty-table", "~> 0.10.0"
  spec.add_runtime_dependency "kontena-websocket-client", "~> 0.1.1"
end
