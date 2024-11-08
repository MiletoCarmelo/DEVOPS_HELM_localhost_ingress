#!/bin/sh

# Obtenir l'IP de minikube
MINIKUBE_IP=$(minikube ip)
if [ -z "$MINIKUBE_IP" ]; then
    echo "Error: Could not get Minikube IP"
    exit 1
fi

# Attendre que le ConfigMap soit créé
echo "Waiting for ingress configuration..."
for i in $(seq 1 30); do
    if kubectl get configmap ingress-domains-config -n dev >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

# Récupérer les domaines du ConfigMap
DOMAINS=$(kubectl get configmap ingress-domains-config -n dev -o jsonpath='{.data.domains}')
if [ -z "$DOMAINS" ]; then
    echo "Error: Could not get domains from ConfigMap"
    exit 1
fi

# Mettre à jour /etc/hosts
HOSTS_ENTRY="$MINIKUBE_IP $DOMAINS"

if grep -q "mm.ch" /etc/hosts; then
    sudo sed -i'.bak' '/mm.ch/d' /etc/hosts
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