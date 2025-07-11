DOCKERNAME = linz-gazetteer-db

.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[.$$() a-zA-Z_0-9-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/$$(IMAGES)/$(IMAGES)/' | \
		sed 's/$$(IMAGES_PUSH)/$(IMAGES_PUSH)/' | \
		awk \
			'BEGIN {FS = ":.*?## "}; \
			{ printf "\033[36m%-30s\033[0m%s%s\n", $$1, "\n ", $$2 }'

.PHONY: docker-12
docker-12: ## Build the $(DOCKERNAME):12 docker image
	docker build -t $(DOCKERNAME):12 \
    --build-arg PGSQL_VERSION=12 \
    .

.PHONY: docker
docker: docker-12 ## Build all versions of the $(DOCKERNAME) docker image

.PHONY: docker-start-12
docker-start-12: ## Start the linz-gazetteer-db:12 docker container
	docker run -d --name gazetteer-db -p 7432:5432 $(DOCKERNAME):12

.PHONY: docker-stop
docker-stop: ## Stop the linz-gazetteer-db docker container
	docker rm -f gazetteer-db

.PHONY: docker-db-shell-12
docker-db-shell-12: ## Start a shell to the containerized db
	docker run --rm -ti --entrypoint bash $(DOCKERNAME):12

.PHONY: docker-connect
docker-connect: ## Connect to the dockerized linz-gazetteer-db db using psql
	PGPASSWORD=******** psql -h localhost -p 7432 -U gaz_web gazetteer
