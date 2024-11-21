#!/bin/bash

# Variables
NAMESPACE="tailscale"

NAMESPACE_localhost="metallb-system"

# Ajouter le repo Tailscale s'il n'existe pas
# if ! helm repo list | grep -q "tailscale"; then
#     echo "🔄 Ajout du repository Helm de Tailscale..."
#     helm repo add tailscale https://pkgs.tailscale.com/helmcharts
#     helm repo update
# fi

# echo
# echo "🔒 Configuration de Tailscale OAuth"

TS_CLIENT_ID=$(grep TS_CLIENT_ID .env | cut -d '=' -f2)
TS_CLIENT_SECRET=$(grep TS_CLIENT_SECRET .env | cut -d '=' -f2)
TS_AUTHKEY=$(grep TS_AUTHKEY .env | cut -d '=' -f2)
TS_DEST_IP=$(grep TS_DEST_IP .env | cut -d '=' -f2)
TS_ROUTES=$(grep TS_ROUTES .env | cut -d '=' -f2)
TS_HOSTNAME=$(grep TS_HOSTNAME .env | cut -d '=' -f2)
TS_IP=$(grep TS_IP .env | cut -d '=' -f2)

LOCALHOST_IP$(grep LOCALHOST_IP .env | cut -d '=' -f2)

# Créer le secret pour TS_AUTHKEY
echo "🔒 Création du secret TS-SECRET .."
kubectl create secret generic ts-secrets \
  --namespace=${NAMESPACE} \
  --from-literal=TS_AUTHKEY=${TS_AUTHKEY} \
  --from-literal=TS_DEST_IP=${TS_DEST_IP} \
  --from-literal=TS_ROUTES=${TS_ROUTES} \
  --from-literal=TS_HOSTNAME=${TS_HOSTNAME} \
  --from-literal=TS_IP=${TS_IP} \
  --dry-run=client -o yaml | kubectl apply -f -


# Créer le secret pour TS_AUTHKEY
echo "🔒 Création du secret LOCALHOST-SECRET .."
kubectl create secret generic localhost-secrets \
  --namespace=${NAMESPACE_localhost} \
  --from-literal=LOCALHOST_IP=${LOCALHOST_IP} \
  --dry-run=client -o yaml | kubectl apply -f -

# Installation de Tailscale avec Helm
# echo "🔒 Installation de Tailscale..."

# helm upgrade --install tailscale-operator tailscale/tailscale-operator \
#   --namespace=${NAMESPACE} \
#   --create-namespace \
#   --set-string ts.oauth.clientId=${TAILSCALE_OAUTH_CLIENT_ID} \
#   --set-string ts.oauth.clientSecret=${TAILSCALE_OAUTH_CLIENT_SECRET} 

echo "🔒 Création du secret operator-oauth .."
kubectl create secret generic operator-oauth \
  --namespace=${NAMESPACE} \
  --from-literal=client_id=${TS_CLIENT_ID} \
  --from-literal=client_secret=${TS_CLIENT_SECRET} \
  --dry-run=client -o yaml | kubectl apply -f -