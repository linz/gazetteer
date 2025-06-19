.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[$$() a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(IMAGES)/$(IMAGES)/' | \
		sed 's/$$(IMAGES_PUSH)/$(IMAGES_PUSH)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker
docker: ## Build all docker images
	make -C src/NZGBplugin/ docker
	make -C src/sql docker

.PHONY: docker-up
docker-up: ## Start the containerized environment
	docker compose up -d

.PHONY: docker-down
docker-down: ## Stop the containerized environment
	docker compose down

.PHONY: docker-qgis-shell
docker-qgis-shell: docker-up ## Start a shell in the containerized qgis (version QGIS_TAG)
	docker compose exec qgis /bin/bash

.PHONY: docker-qgis-start
docker-qgis-start: docker-up ## Start the containerized qgis (version QGIS_TAG)
	xhost +
	docker compose exec qgis sh -c 'DISPLAY=$$1 qgis' sh "$$DISPLAY"

.PHONY: docker-qgis-start-dba
docker-qgis-start-dba: docker-up ## Start the containerized qgis
	xhost +
	docker compose exec qgis sh -c 'DISPLAY=$$1 PGUSER=gazdba PGPASSWORD=gazdba qgis' sh "$$DISPLAY"

.PHONY: docker-qgis-test
docker-qgis-test: docker-up ## Run python tests against QGIS instance (version QGIS_TAG)
	docker compose exec -T qgis sh -c "/usr/bin/xvfb-run --server-args=-screen\ 0\ 1920x1200x24 -- qgis_testrunner.sh tests_directory.run_tests.run_test_modules"

.PHONY: docker-db-connect
docker-db-connect: docker-up ## Connect to the containerized db using psql
	docker compose exec db su postgres -c 'psql gazetteer'

.PHONY: docker-db-test
docker-db-test: docker-up ## Connect to the containerized db using psql
	docker compose exec -T db su postgres -c 'pg_prove -d gazetteer /sql/test/schema/*.sql'
	#docker-compose exec db su postgres -c 'sh /sql/test/run_tests.sh gazetteer'

.PHONY: docker-db-shell
docker-db-shell: docker-up ## Start a shell to the containerized db
	docker compose exec db bash


##################################################
# Targets for src code validation and formating
##################################################

.PHONY: format
format: ##  Apply ruff formatting
	ruff format

.PHONY: formatting-validate
formatting-validate: ## Ensure src code is ruff compliant
	ruff check
