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
docker-qgis-start: docker-up ## Start the containerized qgis
	docker-compose exec qgis sh -c "ln -s  ~/.local/share/QGIS/QGIS3/profiles/default/python/plugins/NZGBplugin/tests /tests_directory" #Containerisation should be a modular for all LINZ plugins tested w. gh actions
	docker-compose exec qgis sh -c "chmod +x /scripts/qgis_testrunner.sh"
	docker-compose exec qgis sh -c "./scripts/qgis_testrunner.sh test_metadata.py"

.PHONY: docker-db-connect
docker-db-connect: docker-up ## Connect to the containerized db using psql
	docker-compose exec db su postgres -c psql gazetteer

.PHONY: docker-db-shell
docker-db-shell: docker-up ## Start a shell to the containerized db
	docker-compose exec db bash
