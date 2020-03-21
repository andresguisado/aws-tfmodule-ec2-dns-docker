#!/bin/bash

# Setup backend state storage.

if [ ! -d ".terraform" ]; then
		terraform init -reconfigure --backend-config="bucket=${TF_VAR_client_name}-terraform-state" --backend-config="key=${TF_VAR_environment}/${TF_VAR_product}-${TF_VAR_region}.tfstate" --backend-config="region=${AWS_DEFAULT_REGION}" --backend-config="encrypt=true"
fi

# pass through TF commands
terraform "$@" 