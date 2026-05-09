# Volcano

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/volcano-sh/volcano)](https://goreportcard.com/report/github.com/volcano-sh/volcano)

A fork of [volcano-sh/volcano](https://github.com/volcano-sh/volcano) — a batch system built on Kubernetes.

Volcano is a batch system built on Kubernetes. It provides a suite of mechanisms that are commonly required by many classes of batch & elastic workloads including:

- Machine Learning/Deep Learning
- Bioinformatics/Genomics
- Other Big Data applications

## Features

- **Queue Management**: Hierarchical queue management with resource allocation policies
- **Gang Scheduling**: Schedule groups of pods together or not at all
- **Fair Scheduling**: Multiple scheduling algorithms including DRF, priority, and proportion
- **Job Management**: Native batch job support with retry policies and lifecycle management
- **Plugin Architecture**: Extensible action and plugin framework for custom scheduling logic

## Prerequisites

- Kubernetes >= 1.24
- Go >= 1.21
- Docker >= 20.10

## Getting Started

### Installation

#### Using Helm

```bash
helm repo add volcano-sh https://volcano-sh.github.io/helm-charts
helm install volcano volcano-sh/volcano --namespace volcano-system --create-namespace
```

#### Building from Source

```bash
# Clone the repository
git clone https://github.com/your-org/volcano.git
cd volcano

# Build all components
make build

# Build Docker images
make images
```

### Development

```bash
# Run code verification (lint, vet, fmt)
make verify

# Run unit tests
make test

# Run e2e tests (requires a running cluster)
# Note: set KUBECONFIG env var to point to your test cluster before running
make e2e
```

## Architecture

Volcano consists of three main components:

| Component | Description |
|-----------|-------------|
| **volcano-scheduler** | Extended Kubernetes scheduler with batch scheduling capabilities |
| **volcano-controller** | Controller manager for Volcano CRDs (Jobs, Queues, PodGroups) |
| **volcano-webhook** | Admission webhook for validating and mutating Volcano resources |

## Contributing

We welcome contributions! Please see our [contribution guidelines](.github/PULL_REQUEST_TEMPLATE.md) and feel free to open issues or pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-feature`)
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/)
4. Push to your branch and open a Pull Request

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

Based on [volcano-sh/volcano](https://github.com/volcano-sh/volcano), Copyright 2019 The Volcano Authors.
