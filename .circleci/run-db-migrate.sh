#!/usr/bin/env bash
set -euo pipefail

# Required ENV vars
: "${CLUSTER_NAME:?Need to set CLUSTER_NAME}"
: "${WORKER_TASK_DEFINITION_NAME:?Need to set WORKER_TASK_DEFINITION_NAME}"
: "${WORKER_CONTAINER_NAME:?Need to set WORKER_CONTAINER_NAME}"
: "${SUBNET_IDS:?Need to set SUBNET_IDS}"
: "${SECURITY_GROUP_IDS:?Need to set SECURITY_GROUP_IDS}"

# Format network config
NETWORK_CONFIG=$(jq -n \
    --argjson subnets "$(echo $SUBNET_IDS | sed 's/[][]//g' | jq -R 'split(",")')" \
    --arg securityGroups $SECURITY_GROUP_IDS \
    '{
        awsvpcConfiguration: {
            subnets: $subnets,
            securityGroups: [$securityGroups],
            assignPublicIp: "DISABLED"
        }
    }')

# Format overrides
OVERRIDES=$(jq -n \
  --arg name "$WORKER_CONTAINER_NAME" \
  '{
    containerOverrides: [
      {
        name: $name,
        command: ["bundle", "exec", "rake", "db:migrate"]
      }
    ]
  }')


# Run the task
aws ecs run-task \
  --cluster "$CLUSTER_NAME" \
  --launch-type FARGATE \
  --task-definition "$WORKER_TASK_DEFINITION_NAME" \
  --network-configuration "$NETWORK_CONFIG" \
  --overrides "$OVERRIDES"
