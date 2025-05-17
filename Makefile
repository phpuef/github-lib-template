.PHONY: install tests install-dev-tools composer

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
    		gouef/phpunit-coverage vendor/bin/phpunit --coverage-text=coverage.txt
coverage:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpunit --coverage-filter=src --coverage-text=coverage.txt --display-deprecations --display-phpunit-deprecation

phpunit-migrate:
		podman run --rm -it \
    		--env XDEBUG_MODE=coverage \
    		--volume $(CURDIR):/app:Z \
    		--workdir /app \
    		gouef/phpunit-coverage vendor/bin/phpunit --migrate-configuration

%:
	@: