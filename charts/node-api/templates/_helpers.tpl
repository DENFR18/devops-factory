{{/*
Expand the name of the chart.
*/}}
{{- define "node-api.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "node-api.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "node-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: cloud-forge
tenant: node-api
{{- end }}

{{/*
Selector labels
*/}}
{{- define "node-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "node-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
