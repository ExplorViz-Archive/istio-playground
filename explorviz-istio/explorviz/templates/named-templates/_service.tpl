{{- define "explorviz.service" -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .component.name }}
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ .component.name }}
spec:
  ports:
  - name: http
    port: 8000
    targetPort: {{ .component.port }}
  selector:
    app: {{ .component.name }}
    version: v1
{{- end }}