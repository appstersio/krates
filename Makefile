# README: http://makefiletutorial.com

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test build teardown up dev

build:
	@docker-compose build --no-cache --force-rm

dev:
	@docker-compose -f docker-compose.dev.yml run --rm devbox

test:
	@docker-compose run -T krates