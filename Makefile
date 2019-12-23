# README: http://makefiletutorial.com
TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.4.9-1
DOCKER_SOCKET = /var/run/docker.sock:/var/run/docker.sock

# Courtesy of: https://stackoverflow.com/a/49524393/3072002
# Common env variables (https://www.gnu.org/software/make/manual/make.html#index-_002eEXPORT_005fALL_005fVARIABLES)
.EXPORT_ALL_VARIABLES:
VERSION=$(shell cat VERSION)

integration: wipe
	docker-compose run toolbox

# -c "./build/travis/before_install.sh && ./build/travis/test_e2e.sh"

master: wipe
	docker run -ti --rm -e "CI=1" -e "TEST_DIR=server" --net host --name master --workdir $(TARGET_PATH) -v $(VOLUME_PATH) \
		-v $(DOCKER_SOCKET) $(RUBY_IMAGE) -c "./build/travis/before_install.sh && ./build/travis/test.sh"
	docker rm -f mongo

worker: wipe
	docker run -ti --rm -e "TEST_DIR=agent" --net host --name worker --workdir $(TARGET_PATH) -v $(VOLUME_PATH) $(RUBY_IMAGE) \
		-c "./build/travis/before_install.sh && ./build/travis/test.sh"

cmd: wipe
	docker run -ti --rm -e "TEST_DIR=cli" --net host --name cmd --workdir $(TARGET_PATH) -v $(VOLUME_PATH) $(RUBY_IMAGE) \
		-c "./build/travis/before_install.sh && ./build/travis/test.sh"

wipe: down
	docker ps -aq | xargs -r docker rm -f

down:
	@docker-compose down