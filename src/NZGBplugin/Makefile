DOCKERNAME = linz-gazetteer-qgis:3.12

.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[$$() a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(DOCKERNAME)/$(DOCKERNAME)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker
docker: ## Build the $(DOCKERNAME) docker image
	docker build -t $(DOCKERNAME) .

.PHONY: docker-qgis-shell
docker-qgis-shell: docker ## Start a shell in the containerized qgis
	docker run -v $(PWD):/plugin --rm -it --name qgis $(DOCKERNAME) /bin/bash

.PHONY: docker-qgis-start
docker-qgis-start: ## Start the containerized qgis
	xhost +
	docker run --rm -it --name qgis -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$$DISPLAY $(DOCKERNAME) qgis
