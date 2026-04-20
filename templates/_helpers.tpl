{{/*
Expand the name of the chart.
*/}}
{{- define "reel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "reel.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "reel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace to use - relies on Helm's release namespace
*/}}
{{- define "reel.namespace" -}}
{{- .Release.Namespace }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "reel.labels" -}}
helm.sh/chart: {{ include "reel.chart" . }}
{{ include "reel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "reel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "reel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Agent selector labels
*/}}
{{- define "reel.agentSelectorLabels" -}}
app.kubernetes.io/name: {{ include "reel.name" . }}
app.kubernetes.io/component: agent
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "reel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "reel.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
