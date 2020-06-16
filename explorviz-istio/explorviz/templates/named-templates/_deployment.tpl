{{- define "explorviz.deployment" -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .component.name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .component.name }}
      version: v1
  template:
    metadata:
      labels:
        app: {{ .component.name }}
        version: v1
    spec:
      containers:
{{- if .component.mongoPort }}
      - image: mongo
        imagePullPolicy: IfNotPresent
        name: mongo-history
        command: ["mongod"]
        args: ["--port", {{ .component.mongoPort | quote }}]
{{- end }}
      - image: {{ .component.image }}
        imagePullPolicy: IfNotPresent
        name: {{ .component.name }}-container
        ports:
        - containerPort: {{ .component.port }}
        env:
{{- if .component.env }}
{{- toYaml .component.env | nindent 8 }}
{{- end }}
{{- if .component.mongoPort }}
        - name: MONGO_HOST
          value: "localhost"
{{- end }}
{{- if .component.kafka }}
        - name: EXCHANGE_KAFKA_BOOTSTRAP_SERVERS
          value: {{ .Release.Name }}-kafka-0.{{ .Release.Name }}-kafka-headless.{{ .Release.Namespace }}.svc.cluster.local:9092
{{- if .component.kafka.topic }}
        - name: EXCHANGE_KAFKA_TOPIC_NAME
          value: "landscape-update"
{{- end }}
{{- end }}
{{- end }}
