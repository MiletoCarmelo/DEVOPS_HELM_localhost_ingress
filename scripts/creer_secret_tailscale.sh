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
TAILSCALE_IP_INGRESS=$(grep TAILSCALE_IP_INGRESS .env | cut -d '=' -f2)

# Créer le secret pour TS_AUTHKEY
echo "🔒 Création du secret Tailscale Auth..."
kubectl create secret generic tailscale-auth \
  --namespace=${NAMESPACE} \
  --from-literal=TS_AUTHKEY=${TAILSCALE_KEY} \
  --dry-run=client -o yaml | kubectl apply -f -

# Créer le secret pour TS_IP_INGRESS
echo "🔒 Création du secret Tailscale IP Ingress..."
kubectl create secret generic tailscale-ip-ingress \
  --namespace=${NAMESPACE} \
  --from-literal=TS_IPINGRESS=${TAILSCALE_IP_INGRESS} \
  --dry-run=client -o yaml | kubectl apply -f -

# Créer le secret pour TS_IPHOSTNAME
echo "🔒 Création du secret Tailscale IP Hostname..."
kubectl create secret generic tailscale-ip-hostname \
  --namespace=${NAMESPACE} \
  --from-literal=TS_IPHOSTNAME=${TAILSCALE_IP_HOSTNAME} \
  --dry-run=client -o yaml | kubectl apply -f -


# Installation de Tailscale avec Helm
echo "🔒 Installation de Tailscale..."

helm upgrade --install tailscale-operator tailscale/tailscale-operator \
  --namespace=${NAMESPACE} \
  --create-namespace \
  --set-string ts.oauth.clientId=${TAILSCALE_OAUTH_CLIENT_ID} \
  --set-string ts.oauth.clientSecret=${TAILSCALE_OAUTH_CLIENT_SECRET} 
