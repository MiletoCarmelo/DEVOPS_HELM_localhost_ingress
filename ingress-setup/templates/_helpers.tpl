{{/*
Expand the name of the chart.
*/}}
{{- define "ingress-setup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create unified labels for ingress-setup components
*/}}
{{- define "ingress-setup.labels" -}}
app.kubernetes.io/name: {{ include "ingress-setup.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Create the name of the TLS secret
*/}}
{{- define "ingress-setup.tlsSecretName" -}}
{{- printf "%s-%s-tls" .Values.module .Values.environment -}}
{{- end }}

{{/*
Determine if TLS is enabled
*/}}
{{- define "ingress-setup.tlsEnabled" -}}
{{- if .Values.tls.enabled }}true{{ else }}false{{ end -}}
{{- end }}