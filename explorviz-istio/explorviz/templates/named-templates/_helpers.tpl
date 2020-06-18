{{- define "explorviz.host" -}}
{{ printf "%s.%s.svc.cluster.local" .component.name .Release.Namespace}}
{{- end }}

{{- define "explorviz.hostUrl" -}}
{{ printf "%s.%s.istio.com" .Release.Name .Release.Namespace }}
{{- end }}
