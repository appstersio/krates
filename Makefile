TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.4.9-1
DOCKER_SOCKET = /var/run/docker.sock:/var/run/docker.sock

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

wipe:
	docker ps -aq | xargs -r docker rm -f