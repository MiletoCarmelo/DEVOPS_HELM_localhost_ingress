#!/bin/bash

# Variables
NAMESPACE="tailscale"

# Ajouter le repo Tailscale s'il n'existe pas
if ! helm repo list | grep -q "tailscale"; then
    echo "🔄 Ajout du repository Helm de Tailscale..."
    helm repo add tailscale https://pkgs.tailscale.com/helmcharts
    helm repo update
fi

echo
echo "🔒 Configuration de Tailscale OAuth"

OAUTH_CLIENT_ID=$(grep OAUTH_CLIENT_ID .env | cut -d '=' -f2)
OAUTH_CLIENT_SECRET=$(grep OAUTH_CLIENT_SECRET .env | cut -d '=' -f2)
TAILSCALE_KEY=$(grep TAILSCALE_KEY .env | cut -d '=' -f2)

# Créer le secret pour TS_AUTHKEY
echo "🔒 Création du secret Tailscale Auth..."
kubectl create secret generic tailscale-auth \
  --namespace=${NAMESPACE} \
  --from-literal=TS_AUTHKEY=${TAILSCALE_KEY} \
  --dry-run=client -o yaml | kubectl apply -f -

# Installation de Tailscale avec Helm
echo "🔒 Installation de Tailscale..."

helm upgrade --install tailscale-operator tailscale/tailscale-operator \
  --namespace=${NAMESPACE} \
  --create-namespace \
  --set-string ts.oauth.clientId=${TAILSCALE_OAUTH_CLIENT_ID} \
  --set-string ts.oauth.clientSecret=${TAILSCALE_OAUTH_CLIENT_SECRET} 
