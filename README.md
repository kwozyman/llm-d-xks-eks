# EKS Cluster Bootstrap (Make + eksctl)

This repository provides a small `Makefile`-driven workflow to create and manage an AWS EKS cluster from a parameterized `eksctl` template.

## Committed Files Used

- `Makefile`: dependency checks, cluster lifecycle, kubeconfig, and NVIDIA GPU Operator deployment via Helm
- `eks-template.yaml`: `eksctl` cluster template rendered with `envsubst` from environment variables

## Prerequisites

Install the tools required by `make check-dependencies`:

- `eksctl`
- `envsubst`
- `helm`

AWS credentials and permissions must be configured in your environment before running cluster commands.

## Configuration

The `Makefile` loads variables from `.env` file in when specified by `$TEMPLATE_FILE` or applies defaults otherwise.

Default values:

- `TEMPLATE_FILE=eks-template.yaml`
- `CLUSTER_NAME=cgament-llmd-1`
- `AWS_REGION=us-east-1`
- `AWS_AZ=us-east-1a`
- `K8S_VERSION=1.30`
- `VPC_CIDR=10.0.0.0/16`
- `ENABLE_EFA=true`
- `ENABLE_PRIVATE_NETWORKING=true`
- `DEFAULT_NODE_GROUP_NAME=gpu-node-group`
- `DEFAULT_INSTANCE_TYPE=g4dn.8xlarge`
- `DEFAULT_MIN_NODES=1`
- `DEFAULT_MAX_NODES=3`
- `DEFAULT_DESIRED_NODES=2`
- `DEFAULT_VOLUME_SIZE=50`
- `GPU_OPERATOR_VERSION=v26.3.1`

Override values in `.env` or on the command line:

```bash
make cluster-create CLUSTER_NAME=my-cluster AWS_REGION=eu-central-1 AWS_AZ=eu-central-1a
```

For GPU instance types that support EFA (for example `p4d.24xlarge`), keep `ENABLE_EFA=true` unless your account or capacity constraints require disabling it.

## Make Targets

Run `make help` for a short usage summary.

- `make check-dependencies`  
  Validates required CLIs are installed.

- `make cluster-show-template`  
  Renders `eks-template.yaml` with current environment values (stdout only).

- `make cluster-create`  
  Renders the template and creates the EKS cluster with `eksctl`.

- `make cluster-delete`  
  Deletes the EKS cluster by name and region.

- `make cluster-kubeconfig`  
  Writes kubeconfig for local `kubectl` access.

- `make deploy-gpuoperator`  
  Adds the NVIDIA Helm repo and installs GPU Operator in namespace `gpu-operator`, with `driver.rdma.enabled=true`.

## Typical Workflow

```bash
make check-dependencies
make cluster-show-template
make cluster-create
make cluster-kubeconfig
make deploy-gpuoperator
```

## Cluster Template Notes

The committed `eks-template.yaml` defines:

- Cluster metadata (`name`, `region`, `version`)
- VPC CIDR
- One managed node group with autoscaler and CloudWatch IAM addon policies
- **EFA** on the node group (`efaEnabled` from `ENABLE_EFA`)
- **Private networking** for the node group (`privateNetworking` from `ENABLE_PRIVATE_NETWORKING`)
- A single availability zone for the node group (`AWS_AZ`)

Adjust `AWS_AZ` to match your chosen region (for example `eu-central-1a` when `AWS_REGION` is `eu-central-1`).
