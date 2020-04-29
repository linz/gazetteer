.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[$$() a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(IMAGES)/$(IMAGES)/' | \
		sed 's/$$(IMAGES_PUSH)/$(IMAGES_PUSH)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker-up
docker-up: ## Start the containerized environment
	docker-compose up -d

.PHONY: docker-down
docker-down: ## Stop the containerized environment
	docker-compose down

.PHONY: docker-qgis-shell
docker-qgis-shell: docker-up ## Start a shell in the containerized qgis
	docker-compose exec qgis /bin/bash

.PHONY: docker-qgis-start
docker-qgis-start: docker-up ## Start the containerized qgis
	xhost +
	docker-compose exec qgis sh -c 'DISPLAY=$$1 qgis' sh "unix$$DISPLAY"

.PHONY: docker-qgis-test
docker-qgis-test: docker-up ## Run python tests agianst QGIS isntance
	docker-compose exec qgis sh -c "export COMPOSE_INTERACTIVE_NO_CLI=1"
	docker-compose exec qgis sh -c "/usr/bin/xvfb-run -- qgis_testrunner.sh tests_directory.run_tests.run_test_modules"

.PHONY: docker-db-connect
docker-db-connect: docker-up ## Connect to the containerized db using psql
	docker-compose exec db su postgres -c psql gazetteer

.PHONY: docker-db-shell
docker-db-shell: docker-up ## Start a shell to the containerized db
	docker-compose exec db bash
