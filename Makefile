# Copyright 2024 The Volcano Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BIN_DIR=_output/bin
RELEASE_DIR=_output/release
GO=go
GOFLAGS?
GOFMT=gofmt
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0-dev")
GIT_COMMIT?=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE?=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
# Personal fork: pushing to my own Docker Hub namespace instead of ghcr.io
REGISTRY?=docker.io/myusername
IMAGE_TAG?=$(VERSION)

LD_FLAGS="-X 'volcano.sh/volcano/pkg/version.Version=$(VERSION)' \
	-X 'volcano.sh/volcano/pkg/version.GitCommit=$(GIT_COMMIT)' \
	-X 'volcano.sh/volcano/pkg/version.BuildDate=$(BUILD_DATE)'"

TARGETS=volcano-scheduler volcano-controller-manager volcano-admission volcano-agent

.PHONY: all
all: build

.PHONY: build
build: $(TARGETS)

.PHONY: $(TARGETS)
$(TARGETS):
	@echo "Building $@..."
	@mkdir -p $(BIN_DIR)
	$(GO) build $(GOFLAGS) -ldflags $(LD_FLAGS) -o $(BIN_DIR)/$@ ./cmd/$@/

.PHONY: images
images:
	@for target in $(TARGETS); do \
		echo "Building image for $$target..."; \
		docker build -t $(REGISTRY)/$$target:$(IMAGE_TAG) \
			--build-arg VERSION=$(VERSION) \
			-f docker/Dockerfile.$$target .; \
	done

.PHONY: push
push:
	@for target in $(TARGETS); do \
		echo "Pushing image $(REGISTRY)/$$target:$(IMAGE_TAG)..."; \
		docker push $(REGISTRY)/$$target:$(IMAGE_TAG); \
	done

# Run tests with race detector enabled by default to catch data races during development
# Note: removed -v and -count=1 here; use `make test-verbose` for full output
.PHONY: test
test:
	$(GO) test $(GOFLAGS) -race ./...

# Verbose test run, useful when debugging a specific failure
.PHONY: test-verbose
test-verbose:
	$(GO) test $(GOFLAGS) -race ./... -v -count=1

.PHONY: test-coverage
test-coverage:
	$(GO) test $(GOFLAGS) ./... -coverprofile=coverage.out -covermode=atomic
	$(GO) tool cover -html=coverage.out -o coverage.html

.PHONY: lint
lint:
	golangci-lint run ./...

.PHONY: fmt
fmt:
	$(GOFMT) -w $$(find . -name '*.go' | grep -v vendor)

.PHONY: fmt-check
fmt-check:
	@diff=$$($(GOFMT) -l $$(find . -name '*.go' | grep -v vendor)); \
	if [ -n "$$diff" ]; then \
		echo "Files not formatted:"; \
		echo "$$diff"; \
		exit 1; \
	fi

.PHONY: vet
vet:
	$(GO) vet ./...

.PHONY: verify
verify: fmt-check vet lint

.PHONY: generate
generate:
	$(GO) generate ./...

.PHONY: clean
clean:
	@rm -rf $(BIN_DIR) $(RELEASE_DIR) coverage.out coverage.html
	@echo "Cleaned build artifacts."

# dev: build, run tests, and verify formatting in one shot — handy for a quick pre-commit check
.PHONY: dev
dev: build test verify

# Shortcut to
