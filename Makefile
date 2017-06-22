IMAGE_FILE?=image.yaml
COMMIT?=$(shell git rev-parse HEAD | cut -c1-8)
IMAGE_VERSION?=latest
REPO?=$(shell cat $(IMAGE_FILE) | grep "^name:" | cut -d' ' -f2)
DOCKER_BUILD_OPTS?=
ARTIFACT_DIR=${CURDIR}/build/distributions
DOCKER?=docker
TAG?=latest

ifdef TRAVIS_TAG
	TAG=$(TRAVIS_TAG)
endif

all:
	tar -czf ragent-$(TAG).tar.gz *.js

build:
	echo "Running docker build $(REPO)"
	mkdir -p $(CURDIR)/build
	cp -r $(CURDIR)/*.tar.gz $(CURDIR)/build/
	mkdir -p /tmp/repos
	cp -rf /etc/yum.repos.d/rhel-base-os.repo /tmp/repos/
	dogen --repo-files-dir /tmp/repos --scripts $(CURDIR)/scripts --verbose $(IMAGE_FILE) $(CURDIR)/build
	$(DOCKER) build $(DOCKER_BUILD_OPTS) -t $(REPO):$(COMMIT) $(CURDIR)/build

push:
	$(DOCKER) tag $(REPO):$(COMMIT) $(DOCKER_REGISTRY)/$(REPO):$(COMMIT)
	$(DOCKER) push $(DOCKER_REGISTRY)/$(REPO):$(COMMIT)

snapshot:
	$(DOCKER) tag $(REPO):$(COMMIT) $(DOCKER_REGISTRY)/$(REPO):$(IMAGE_VERSION)
	$(DOCKER) push $(DOCKER_REGISTRY)/$(REPO):$(IMAGE_VERSION)


clean:
	rm -rf build ragent-$(TAG).tar.gz

.PHONY: build push snapshot clean
