# README: http://makefiletutorial.com
TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.6.5-3
DOCKER_SOCKET = /var/run/docker.sock:/var/run/docker.sock

# Courtesy of: https://stackoverflow.com/a/49524393/3072002
# Common env variables (https://www.gnu.org/software/make/manual/make.html#index-_002eEXPORT_005fALL_005fVARIABLES)
.EXPORT_ALL_VARIABLES:
VERSION=$(shell cat VERSION)

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: build version

version:
	@echo $(VERSION) > version
	@echo $(VERSION) > server/version
	@echo $(VERSION) > agent/version
	@echo $(VERSION) > cli/version
	@git commit --all --message "Krates: New version 'v$(VERSION)' release"
	@git tag --force "v$(VERSION)"

pry-test:
	@docker-compose run --no-deps -e "TRACE=1" toolbox -c "./build/travis/before_install.sh && ./build/travis/test_e2e.sh"

pry-master: LOG_LEVEL=error
pry-master: PRY_SESSION=yes
pry-master: wipe-exited
	@docker-compose run --service-ports -u root master

publish_images:
	@docker run -ti --rm -e "TEST_DIR=cli" --net host --name cmd -e "DOCKER_HUB_USER=$(DOCKER_HUB_USER)" -e "DOCKER_HUB_PASSWORD=$(DOCKER_HUB_PASSWORD)" --workdir $(TARGET_PATH) -v $(VOLUME_PATH) -v "/var/run/docker.sock:/var/run/docker.sock:ro" $(RUBY_IMAGE) \
		-c "./build/travis/deploy.sh"

publish_cmd: wipe
	@docker run -ti --rm -e "TEST_DIR=cli" --net host --name cmd -e "RUBYGEMS_KEY=$(RUBYGEMS_KEY)" --workdir $(TARGET_PATH) -v $(VOLUME_PATH) $(RUBY_IMAGE) \
		-c "./build/travis/deploy_gem.sh"

integration: export COMPOSE_FILE=docker-compose.yml:docker-compose.ci.yml
integration: wipe
	docker-compose run -e "TRACE=${TRACE}" toolbox -c "./build/travis/before_install.sh && ./build/travis/test_e2e.sh"

master: wipe
	docker run -ti --rm -e "CI=1" -e "TEST_DIR=server" -e "TRACE=${TRACE}" -e "LOG_LEVEL=ERROR" --net host --name master --workdir $(TARGET_PATH) -v $(VOLUME_PATH) \
		-v $(DOCKER_SOCKET) $(RUBY_IMAGE) -c "./build/travis/before_install.sh && ./build/travis/test.sh"
	docker rm -f mongo

worker: wipe
	docker run -ti --rm -e "TEST_DIR=agent" -e "TRACE=${TRACE}" --net host --name worker --workdir $(TARGET_PATH) -v $(VOLUME_PATH) $(RUBY_IMAGE) \
		-c "./build/travis/before_install.sh && ./build/travis/test.sh"

cmd: wipe
	docker run -ti --rm -e "TEST_DIR=cli" -e "TRACE=${TRACE}" -e "LOG_LEVEL=ERROR" --net host --name cmd --workdir $(TARGET_PATH) -v $(VOLUME_PATH) $(RUBY_IMAGE) \
		-c "./build/travis/before_install.sh && ./build/travis/test.sh"

build:
	@docker-compose build --no-cache && \
		echo "OK: Successfuly built all the required components..."

wipe: down volumes
	docker ps -aq | xargs -r docker rm -f

wipe-exited:
	docker ps -aq -f "status=exited" | xargs -r docker rm -f

down:
	@docker-compose down

volumes:
	@docker volume prune --force

prune:
	@git checkout master
	@git pull
	@git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d