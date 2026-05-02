{{/*
Expand the name of the chart.
*/}}
{{- define "react.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "react.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "react.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: cloud-forge
tenant: react
{{- end }}

{{/*
Selector labels
*/}}
{{- define "react.selectorLabels" -}}
app.kubernetes.io/name: {{ include "react.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
