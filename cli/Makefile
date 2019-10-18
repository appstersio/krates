# README: http://makefiletutorial.com
GEM_NAME = krates
FS_NAME     = fskr
VOLUME_NAME = krates
FS_PATH     = $(FS_NAME):/src
VOLUME_PATH = $(VOLUME_NAME):/src

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test build teardown up dev gemspec credspec teardown

# Courtesy of: https://stackoverflow.com/a/49524393/3072002
# Common env variables (https://www.gnu.org/software/make/manual/make.html#index-_002eEXPORT_005fALL_005fVARIABLES)
.EXPORT_ALL_VARIABLES:
COMPOSE_FILE=../docker-compose.yml:../docker-compose.r.yml

# Command-line integration
build:
	@docker-compose build --no-cache --force-rm buildbox

up:
	@docker-compose up -d krates && sleep 5 && \
		echo "OK: Successfuly launched all the required components..."

# Override environment variables for DEV environment
dev: export COMPOSE_FILE=../docker-compose.yml:../docker-compose.d.yml
dev:
	@docker-compose run --rm krates

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

volume-init:
	@docker volume rm -f $(VOLUME_NAME) > /dev/null && \
		docker container create --name $(FS_NAME) -v $(VOLUME_PATH) busybox > /dev/null && \
		docker cp . $(FS_PATH) && docker rm $(FS_NAME) > /dev/null

teardown:
	@docker-compose down && \
		echo "OK: Successfuly shutdown and removed all the required components..."