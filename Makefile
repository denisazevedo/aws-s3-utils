APP_NAME=fluid-s3-presign

REGISTRY_URL=registry.gitlab.com/fluidapi/utils/$(APP_NAME)

BRANCH := $(shell git rev-parse --abbrev-ref HEAD | tr / -)
COMMIT := $(shell git rev-parse --short HEAD)
DATE := $(shell git log -1 --format=%cd --date=format:"%Y%m%d")
VERSION ?= $(DATE).$(COMMIT)
TAG=$(BRANCH)-$(VERSION)

all: build start
# dev: build up

.DEFAULT_GOAL := help

.PHONY: logs clean

# --------------------------------------------------------------------------------

# clean: update-go-deps

# clean:
# 	# @docker system prune --volumes --force
# 	@docker system prune --force

login:
	$(info Make: Login to Docker Hub.)
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASS) $(DOCKER_REGISTRY)

.PHONY: build
build:  ## Build the Docker image
	@docker build -t $(REGISTRY_URL):$(TAG) \
		--build-arg GITLAB_USER=$(GITLAB_USER) --build-arg GITLAB_TOKEN=$(GITLAB_TOKEN) \
		--build-arg VERSION=$(TAG) .

.PHONY: push
push:  ## Push the Docker image to registry
	@docker push $(REGISTRY_URL):$(TAG)
	@echo Done, built image: $(REGISTRY_URL):$(TAG)

.PHONY: docker
docker: build push  ## Build and push the Docker image

.PHONY: run-local
run-local:  ## Run the application in a Docker container
	@docker run --rm --name $(APP_NAME) --net=host --env-file .env $(REGISTRY_URL):$(TAG)

.PHONY: kill-local
kill-local: ## Force remove the container
	@docker rm -f $(APP_NAME)

help:  ## Help target to show available commands with information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) |  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
