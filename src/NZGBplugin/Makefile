DOCKERNAME = linz-gazetteer-qgis

.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[$$() \.a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(DOCKERNAME)/$(DOCKERNAME)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker-3.10
docker-3.10: ## Build the $(DOCKERNAME):3.10 docker image
	docker build -t $(DOCKERNAME):3.10 --build-arg UPSTREAM_TAG=release-3_10 .

.PHONY: docker
docker: docker-3.10 ## Build all versions of the $(DOCKERNAME) docker image

.PHONY: docker-qgis-shell-3.10
docker-qgis-shell-3.10: docker-3.10 ## Start a shell in the containerized qgis 3.10
	docker run -v $(PWD):/plugin --rm -it --name qgis $(DOCKERNAME):3.10 /bin/bash

.PHONY: docker-qgis-start-3.10
docker-qgis-start-3.10: ## Start the containerized qgis 3.10
	xhost +
	docker run --rm -it --name qgis -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$$DISPLAY $(DOCKERNAME):3.10 qgis
