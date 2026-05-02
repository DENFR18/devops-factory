{{/*
Expand the name of the chart.
*/}}
{{- define "service-alpha.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "service-alpha.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "service-alpha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: cloud-forge
tenant: alpha
{{- end }}

{{/*
Selector labels
*/}}
{{- define "service-alpha.selectorLabels" -}}
app.kubernetes.io/name: {{ include "service-alpha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
