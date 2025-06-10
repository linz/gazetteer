DOCKERNAME = linz-gazetteer-qgis

.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[$$() \.a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(DOCKERNAME)/$(DOCKERNAME)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker-3.28
docker-3.28: ## Build the $(DOCKERNAME):3.28 docker image
	docker build -t $(DOCKERNAME):3.28 --build-arg UPSTREAM_TAG=release-3_28 .

.PHONY: docker
docker: docker-3.28 ## Build all versions of the $(DOCKERNAME) docker image

.PHONY: docker-qgis-shell-3.28
docker-qgis-shell-3.28: docker-3.28 ## Start a shell in the containerized qgis 3.28
	docker run -v $(PWD):/plugin --rm -it --name qgis $(DOCKERNAME):3.28 /bin/bash

.PHONY: docker-qgis-start-3.28
docker-qgis-start-3.28: ## Start the containerized qgis 3.28
	xhost +
	docker run --rm -it --name qgis -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$$DISPLAY $(DOCKERNAME):3.28 qgis
