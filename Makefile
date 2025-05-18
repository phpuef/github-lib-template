.PHONY: install tests install-dev-tools composer coverage phpunit-migrate phpstan cs csf cs-debug

COMPOSER_HOME ?= $(HOME)/.config/composer
COMPOSER_CACHE_DIR ?= $(HOME)/.cache/composer

install-dev-tools:
	podman pull composer

composer:
	@mkdir -p $(COMPOSER_HOME) $(COMPOSER_CACHE_DIR)
	podman run --rm --interactive --tty \
             --env COMPOSER_HOME=$(COMPOSER_HOME) \
             --env COMPOSER_CACHE_DIR=$(COMPOSER_CACHE_DIR) \
             --volume $(COMPOSER_HOME):$(COMPOSER_HOME):Z \
             --volume $(COMPOSER_CACHE_DIR):$(COMPOSER_CACHE_DIR):Z \
             --volume $(CURDIR):/app:Z \
             composer $(filter-out $@,$(MAKECMDGOALS))

install:
	$(MAKE) composer install

tests:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpunit --coverage-filter=src --coverage-text=coverage.txt
coverage:
		rm -rf .phpunit.result.cache .phpunit.cache coverage && podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpunit --coverage-filter=src --coverage-text=coverage.txt --coverage-clover=coverage.xml --coverage-html=coverage --display-deprecations --display-phpunit-deprecation --do-not-cache-result

phpunit-migrate:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpunit --migrate-configuration

phpstan:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpstan analyse

cs:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpcs --standard=ruleset.xml src tests

cs-debug:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpcs --standard=ruleset.xml src tests

csf:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpcbf --standard=ruleset.xml src tests
%:
	@: