.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[$$() a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(IMAGES)/$(IMAGES)/' | \
		sed 's/$$(IMAGES_PUSH)/$(IMAGES_PUSH)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker-qgis-start
docker-qgis-start: ## Start the containerized qgis
	xhost +
	docker run --rm -it --name qgis -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$$DISPLAY qgis/qgis:release-3_4 qgis

