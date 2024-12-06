#!/bin/bash

# Variables
NAMESPACE="tailscale"
NAMESPACE_localhost="metallb-system"

# Lecture des variables depuis .env
TS_CLIENT_ID=$(grep TS_CLIENT_ID .env | cut -d '=' -f2)
TS_CLIENT_SECRET=$(grep TS_CLIENT_SECRET .env | cut -d '=' -f2)
TS_AUTHKEY=$(grep TS_AUTHKEY .env | cut -d '=' -f2)
TS_DEST_IP=$(grep TS_DEST_IP .env | cut -d '=' -f2)
TS_ROUTES=$(grep TS_ROUTES .env | cut -d '=' -f2)
TS_HOSTNAME=$(grep TS_HOSTNAME .env | cut -d '=' -f2)

# Lecture de l'IP Tailscale et ajout du masque CIDR si nécessaire
TS_IP=$(grep TS_IP .env | cut -d '=' -f2)
if [[ ! $TS_IP =~ /[0-9]{1,2}$ ]]; then
    TS_IP="${TS_IP}/32"
    echo "ℹ️  Ajout du masque CIDR à l'adresse IP Tailscale: ${TS_IP}"
fi

# Lecture de l'IP Localhost - gestion spéciale pour les plages d'adresses
LOCALHOST_IP=$(grep LOCALHOST_IP .env | cut -d '=' -f2)
if [[ $LOCALHOST_IP =~ "-" ]]; then
    # C'est une plage d'adresses, pas besoin d'ajouter /32
    echo "ℹ️  Utilisation de la plage d'adresses pour Localhost: ${LOCALHOST_IP}"
else
    # C'est une adresse unique, ajouter /32
    if [[ ! $LOCALHOST_IP =~ /[0-9]{1,2}$ ]]; then
        LOCALHOST_IP="${LOCALHOST_IP}/32"
        echo "ℹ️  Ajout du masque CIDR à l'adresse IP Localhost: ${LOCALHOST_IP}"
    fi
fi

# Création des namespaces si nécessaire
for NS in "$NAMESPACE" "$NAMESPACE_localhost"; do
    if ! kubectl get namespace "$NS" >/dev/null 2>&1; then
        echo "🔄 Création du namespace ${NS}..."
        kubectl create namespace "$NS"
    fi
done

# Création du secret TS-SECRET
echo "🔒 Création du secret TS-SECRET .."
kubectl create secret generic ts-secrets \
    --namespace=${NAMESPACE} \
    --from-literal=TS_AUTHKEY=${TS_AUTHKEY} \
    --from-literal=TS_DEST_IP=${TS_DEST_IP} \
    --from-literal=TS_ROUTES=${TS_ROUTES} \
    --from-literal=TS_HOSTNAME=${TS_HOSTNAME} \
    --from-literal=TS_IP=${TS_IP} \
    --dry-run=client -o yaml | kubectl apply -f -

# Création du secret LOCALHOST-SECRET
echo "🔒 Création du secret LOCALHOST-SECRET .."
kubectl create secret generic localhost-secrets \
    --namespace=${NAMESPACE_localhost} \
    --from-literal=LOCALHOST_IP=${LOCALHOST_IP} \
    --dry-run=client -o yaml | kubectl apply -f -

# Création du secret operator-oauth
echo "🔒 Création du secret operator-oauth .."
kubectl create secret generic operator-oauth \
    --namespace=${NAMESPACE} \
    --from-literal=client_id=${TS_CLIENT_ID} \
    --from-literal=client_secret=${TS_CLIENT_SECRET} \
    --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Configuration terminée"