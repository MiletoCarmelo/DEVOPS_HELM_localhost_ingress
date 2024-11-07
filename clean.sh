#!/bin/bash

NAMESPACE="dev"
MODULE="ingress-setup"
ENV="dev"

echo "Starting cleanup..."

# Delete all related resources
kubectl delete secret -n $NAMESPACE $MODULE-$ENV-tls --ignore-not-found
kubectl delete certificate -n $NAMESPACE $MODULE-$ENV-certificate --ignore-not-found
kubectl delete clusterissuer $MODULE-$ENV-issuer --ignore-not-found
kubectl delete ingress -n $NAMESPACE $MODULE-$ENV-ingress --ignore-not-found

# Delete the helm release
helm uninstall $MODULE -n $NAMESPACE

# Wait for resources to be deleted
echo "Waiting for resources to be deleted..."
sleep 10

echo "Cleanup completed"