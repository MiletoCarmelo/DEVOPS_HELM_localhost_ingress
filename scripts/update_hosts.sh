#!/bin/sh

# Attendre que le ConfigMap soit créé
echo "Waiting for ingress configuration..."
for i in $(seq 1 30); do
    if kubectl get configmap ingress-domains-config -n dev >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

# Récupérer les informations du ConfigMap
INGRESS_IP=$(kubectl get configmap ingress-domains-config -n dev -o jsonpath='{.data.ingress_ip}')
DOMAINS=$(kubectl get configmap ingress-domains-config -n dev -o jsonpath='{.data.domains}')

if [ -z "$INGRESS_IP" ] || [ -z "$DOMAINS" ]; then
    echo "Error: Could not get ingress configuration"
    exit 1
fi

# Mettre à jour /etc/hosts
HOSTS_ENTRY="$INGRESS_IP $DOMAINS"

if grep -q "mm.ch" /etc/hosts; then
    sudo sed -i'.bak' '/mm.ch/d' /etc/hosts
fi

echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
echo "Updated /etc/hosts with: $HOSTS_ENTRY"
