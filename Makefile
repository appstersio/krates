# README: http://makefiletutorial.com
GEM_NAME = krates

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test build teardown up dev

build:
	@docker-compose build --no-cache --force-rm

release-up:
	@docker-compose up -d && sleep 5 && \
		echo "OK: Successfuly launched all the required components..."

dev:
	@docker-compose -f docker-compose.dev.yml run --rm devbox

test:
	@docker-compose exec -T krates bundle exec rspec

gemspec:
	@docker-compose exec -T krates gem build $(GEM_NAME) && \
		echo "OK: Successfuly built .gem file that includes the plugin..."

# NOTE: This is a temporary task until gem has released 3.1.0 version
credspec:
	@docker-compose exec -T krates bash -c "echo :rubygems_api_key: $$(kontena vault read --value KRATES_GEM_HOST_API_KEY) > ~/.gem/credentials && chmod 0600 ~/.gem/credentials" && \
		echo "OK: Successfuly saved credspec file for publishing..."

publish:
	@docker-compose exec -T krates bash -c "gem push $$(basename $(GEM_NAME)*.gem)" && \
		echo "OK: Successfuly published plugin to RubyGems.org..."

teardown:
	@docker-compose down && \
		echo "OK: Successfuly shutdown and removed all the required components..."