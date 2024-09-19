#!/bin/bash

# Define the manifests in the desired order
MANIFESTS=(
  "namespace.yml"
  "postgres-cm.yml"
  "django-cm.yml"
  "postgres-pv.yml"
  "postgres-pvc.yml"
  "postgres-sts.yml"
  "postgres-service.yml"
  "django-deployment.yml"
  "django-service.yml"
  "ingress.yml"
)

echo "Changing directory"

# Check if the 'kubernetes' directory exists and navigate to it
if [ -d "kubernetes" ]; then
  cd kubernetes
else
  echo "Directory 'kubernetes' does not exist."
  exit 1
fi

# Apply the namespace and PostgreSQL manifests
echo "Applying namespace and PostgreSQL manifests..."
for manifest in "${MANIFESTS[@]}"; do
  if [[ "$manifest" == "namespace.yml" || "$manifest" == "postgres-cm.yml" || "$manifest" == "postgres-pv.yml" || "$manifest" == "postgres-pvc.yml" || "$manifest" == "postgres-sts.yml" || "$manifest" == "postgres-service.yml" ]]; then
    if [ -f "$manifest" ]; then
      echo "Applying $manifest"
      kubectl apply -f "$manifest"
      if [ $? -ne 0 ]; then
        echo "Failed to apply $manifest"
        exit 1
      fi
    else
      echo "Manifest file '$manifest' not found."
      exit 1
    fi
  fi
done

# Wait for PostgreSQL StatefulSet pods to be ready
echo "Waiting for PostgreSQL StatefulSet pods to be ready..."
while true; do
  PODS_READY=$(kubectl get pods -n django-app -l app=postgres -o jsonpath='{.items[*].status.phase}' | grep -w Running | wc -w)
  TOTAL_PODS=$(kubectl get pods -n django-app -l app=postgres -o jsonpath='{.items[*].metadata.name}' | wc -w)
  if [ "$PODS_READY" -eq "$TOTAL_PODS" ]; then
    echo "PostgreSQL StatefulSet pods are up and running."
    break
  else
    echo "Waiting for PostgreSQL StatefulSet pods to be ready..."
    sleep 10
  fi
done

# Wait for PostgreSQL Service to be ready
echo "Waiting for PostgreSQL Service to be available..."
while true; do
  SERVICE_READY=$(kubectl get svc postgres-service -n django-app -o jsonpath='{.spec.clusterIP}')
  if [ -n "$SERVICE_READY" ]; then
    echo "PostgreSQL Service is available."
    break
  else
    echo "Waiting for PostgreSQL Service to be available..."
    sleep 10
  fi
done

# Apply the remaining manifests
echo "Applying remaining manifests..."
for manifest in "${MANIFESTS[@]}"; do
  if [[ "$manifest" == "django-deployment.yml" || "$manifest" == "django-service.yml" || "$manifest" == "ingress.yml" ]]; then
    if [ -f "$manifest" ]; then
      echo "Applying $manifest"
      kubectl apply -f "$manifest"
      if [ $? -ne 0 ]; then
        echo "Failed to apply $manifest"
        exit 1
      fi
    else
      echo "Manifest file '$manifest' not found."
      exit 1
    fi
  fi
done

echo "Finished..."
