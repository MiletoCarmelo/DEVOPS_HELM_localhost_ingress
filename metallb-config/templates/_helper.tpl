# templates/_helpers.tpl
{{- define "metallb-config.loadSecret" -}}
tsIP={{ `{{- ( index ( lookup "v1" "Secret" .Values.ipAddressPools.tailscale.namespace .Values.ipAddressPools.tailscale.secretRef.name ).data .Values.ipAddressPools.tailscale.secretRef.key | b64dec ) -}}` }}
{{- end }}