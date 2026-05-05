# Load environment variables from .env file if it exists
ifneq (,$(wildcard ./.env))
    include .env
endif

# Export variables so envsubst can consume Make defaults and overrides
export

# Fallback defaults in case .env is missing or specific vars are not set
TEMPLATE_FILE ?= eks_template.yaml
CLUSTER_NAME ?= cgament-llmd-1
AWS_REGION ?= us-east-1
K8S_VERSION ?= 1.30
VPC_CIDR ?= 10.0.0.0/16
DEFAULT_NODE_GROUP_NAME ?= gpu-node-group
DEFAULT_INSTANCE_TYPE ?= g4dn.8xlarge
DEFAULT_MIN_NODES ?= 1
DEFAULT_MAX_NODES ?= 3
DEFAULT_DESIRED_NODES ?= 2
DEFAULT_VOLUME_SIZE ?= 50
GPU_OPERATOR_VERSION ?= v26.3.1

help:
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@echo "  check-dependencies - Check if the dependencies are installed"
	@echo "  cluster-show-template - Show the rendered YAML without creating the cluster"
	@echo "  cluster-create - Create the EKS cluster"
	@echo "  cluster-delete - Delete the EKS cluster and all associated resources"
	@echo "  cluster-kubeconfig - Update local kubeconfig to connect to the cluster"
	@echo "  deploy-gpuoperator - Deploy Nvidia GPU Operator"

check-dependencies:
	@echo "Checking dependencies..."
	@which eksctl >/dev/null 2>&1 || { echo "Error: eksctl is not installed. Please install it from https://eksctl.io/"; exit 1; }
	@which envsubst >/dev/null 2>&1 || { echo "Error: envsubst is not installed. Please install it on your system."; exit 1; }
	@which helm >/dev/null 2>&1 || { echo "Error: helm is not installed. Please install it from https://helm.sh/docs/intro/install/"; exit 1; }
	@echo "All good!"

cluster-show-template: ## Renders the template with current env vars to standard output
	@envsubst < $(TEMPLATE_FILE)

cluster-create: ## Creates the EKS cluster
	@echo "Creating EKS cluster $(CLUSTER_NAME) in $(AWS_REGION)..."
	@envsubst < $(TEMPLATE_FILE) | eksctl create cluster -f -

cluster-delete: ## Deletes the EKS cluster
	@echo "Deleting EKS cluster $(CLUSTER_NAME) in $(AWS_REGION)..."
	eksctl delete cluster --name=$(CLUSTER_NAME) --region=$(AWS_REGION) 

cluster-kubeconfig: ## Updates the local kubeconfig
	eksctl utils write-kubeconfig --cluster=$(CLUSTER_NAME) --region=$(AWS_REGION) --auto-kubeconfig=true

deploy-gpuoperator:
	@echo "Deploying Nvidia GPU Operator"
	helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
	helm repo update
	helm install --wait -n gpu-operator --create-namespace \
		gpu-operator nvidia/gpu-operator \
		--version "${GPU_OPERATOR_VERSION}" \
		--set "driver.rdma.enabled=true"
