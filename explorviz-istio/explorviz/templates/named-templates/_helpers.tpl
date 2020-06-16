{{- define "explorviz.host" -}}
{{ printf "%s.%s.svc.cluster.local" .component.name .Release.Namespace}}
{{- end }}
