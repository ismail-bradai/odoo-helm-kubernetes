
{{/*

Nom complet de l'application

*/}}

{{- define "odoo.fullname" -}}

{{- printf "odoo-%s" .Values.environment }}

{{- end }}



{{/*

Labels communs

*/}}

{{- define "odoo.labels" -}}

app: odoo

environment: {{ .Values.environment }}

helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}

app.kubernetes.io/managed-by: {{ .Release.Service }}

{{- end }}



{{/*

Selector labels

*/}}

{{- define "odoo.selectorLabels" -}}

app: odoo

environment: {{ .Values.environment }}

{{- end }}

