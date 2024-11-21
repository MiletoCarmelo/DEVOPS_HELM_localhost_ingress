# metallb/templates/_helpers.tpl
{{- define "metallb.getSecretValue" -}}
{{- $secret := (lookup "v1" "Secret" .context.Release.Namespace .secret.name) }}
{{- if $secret }}
{{- index $secret.data .secret.key | b64dec -}}
{{- end }}
{{- end }}