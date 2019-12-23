TARGET_PATH = /src/app
VOLUME_PATH = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE  = krates/toolbox:2.4.9-1

cmd:
	docker run -ti --rm -e "TEST_DIR=cli" --net host --name rx --workdir $(TARGET_PATH) -v $(VOLUME_PATH) $(RUBY_IMAGE) \
		-c "./build/travis/before_install.sh && ./build/travis/test.sh"