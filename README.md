# EKS Cluster Bootstrap (Make + eksctl)

This repository provides a small `Makefile`-driven workflow to create and manage an AWS EKS cluster from a parameterized `eksctl` template.

## Committed Files Used

- `Makefile`: automation targets for dependency checks, cluster lifecycle, kubeconfig, and GPU Operator deployment
- `eks_template.yaml`: `eksctl` cluster template rendered via environment variables

## Prerequisites

Install the tools required by `make check-dependencies`:

- `eksctl`
- `envsubst`
- `helm`

AWS credentials and permissions must be configured in your environment before running cluster commands.

## Configuration

The `Makefile` loads variables from `.env` when present and provides defaults otherwise.

Default values:

- `TEMPLATE_FILE=eks_template.yaml`
- `CLUSTER_NAME=cgament-llmd-1`
- `AWS_REGION=us-east-1`
- `K8S_VERSION=1.30`
- `VPC_CIDR=10.0.0.0/16`
- `DEFAULT_NODE_GROUP_NAME=gpu-node-group`
- `DEFAULT_INSTANCE_TYPE=g4dn.8xlarge`
- `DEFAULT_MIN_NODES=1`
- `DEFAULT_MAX_NODES=3`
- `DEFAULT_DESIRED_NODES=2`
- `DEFAULT_VOLUME_SIZE=50`
- `GPU_OPERATOR_VERSION=v26.3.1`

You can override any value either in `.env` or inline:

```bash
make cluster-create CLUSTER_NAME=my-cluster AWS_REGION=eu-central-1
```

## Make Targets

- `make check-dependencies`  
  Validates required CLIs are installed.

- `make cluster-show-template`  
  Renders `eks_template.yaml` with current environment values.

- `make cluster-create`  
  Renders the template and creates the EKS cluster with `eksctl`.

- `make cluster-delete`  
  Deletes the EKS cluster by name and region.

- `make cluster-kubeconfig`  
  Writes kubeconfig for local `kubectl` access.

- `make deploy-gpuoperator`  
  Installs NVIDIA GPU Operator via Helm (namespace `gpu-operator`).

## Typical Workflow

```bash
make check-dependencies
make cluster-show-template
make cluster-create
make cluster-kubeconfig
make deploy-gpuoperator
```

## Cluster Template Notes

The committed `eks_template.yaml` defines:

- cluster metadata (`name`, `region`, `version`)
- VPC CIDR block
- one managed node group with autoscaler and CloudWatch addon policies enabled

