#!/bin/sh

# Obtenir l'IP de minikube
MINIKUBE_IP=$(minikube ip)
if [ -z "$MINIKUBE_IP" ]; then
    echo "Error: Could not get Minikube IP"
    exit 1
fi

# Mettre à jour /etc/hosts
DOMAIN="dev.mm.ch"
HOSTS_ENTRY="$MINIKUBE_IP $DOMAIN"

if grep -q "$DOMAIN" /etc/hosts; then
    sudo sed -i'.bak' "/$DOMAIN/d" /etc/hosts
fi

echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
echo "Updated /etc/hosts with: $HOSTS_ENTRY"

# Démarrer le tunnel minikube si pas déjà en cours
if ! pgrep -f "minikube tunnel" > /dev/null; then
    echo "Starting Minikube tunnel..."
    nohup minikube tunnel > /tmp/minikube-tunnel.log 2>&1 &
    echo "Minikube tunnel started"
else
    echo "Minikube tunnel already running"
fi