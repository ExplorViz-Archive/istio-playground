{{- define "explorviz.host" -}}
{{ printf "%s.%s.svc.cluster.local" .component.name .Values.namespace}}
{{- end }}
