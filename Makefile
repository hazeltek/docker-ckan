VERSION := $(shell git describe --tags --exact-match 2>/dev/null || echo 2.7.8)
DOCKERHUB_NAMESPACE ?= hazeltek
IMAGE := ${DOCKERHUB_NAMESPACE}/ckan:${VERSION}-alpine

build:
	docker build -t ${IMAGE} rootfs

build-no-cache:
	docker build --no-cache -t ${IMAGE} rootfs

push: build
	docker push ${IMAGE}
