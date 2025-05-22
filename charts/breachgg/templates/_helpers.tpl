{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
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
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Converts environemnt variable name into key vault secret name
*/}}
{{ define "keyvault.varNameFromEnvName" -}}
	{{- if . -}}
        {{- replace "_" "-" . -}}
    {{- end -}}
{{ end -}}

{{/*
azure keyvault driver object item definition
*/}}
{{ define "keyvault.defineObjectItemJson" -}}
{{ toJson (dict "objectName" (include "keyvault.varNameFromEnvName" .name) "objectType" .type "objectAlias" .name) }}
{{- end -}}

{{- define "keyvault.generateObjectList" -}}
{{- $secretsVars := splitList ";" (include "object.uniqueCommaSeparatedListFromObjectsList" .secrets) -}}
array:
{{- range $secretsVar := $secretsVars }}
  - |
    objectName: "{{ include "keyvault.varNameFromEnvName" $secretsVar }}"
    objectType: secret
{{- end }}
{{- end -}}

{{- define "keyvault.secretObjectYaml" -}}
  {{- $allItems := list -}}
  {{- range $type, $envNames := .secrets }}
    {{- $secretName := printf "%s-secrets" $type -}}
    {{- $sublist := list -}}
    {{- range $envName := $envNames }}
      {{- $sublist = append $sublist (dict "objectName" (include "keyvault.varNameFromEnvName" $envName) "key" $envName) -}}
    {{- end }}
    {{- $allItems = append $allItems (dict "secretName" $secretName "type" "Opaque" "data" $sublist) -}}
  {{- end -}}
  {{ $allItems | toYaml }}
{{- end -}}

{{/*
Helper that returns unique json list from objects that has values lists
*/}}
{{- define "object.uniqueCommaSeparatedListFromObjectsList" -}}
  {{- $uniqueValues := (list) -}}
    {{- range $type, $items := . -}}
      {{- range $item := $items -}}
          {{- $uniqueValues = append $uniqueValues $item -}}
    {{- end -}}
  {{- end -}}
  {{- join ";" ($uniqueValues | uniq | sortAlpha) -}}
{{- end -}}

{{/*
   Helper for easier to add traefik anotations
*/}}
{{- define "loadBalancer.labels.generic" -}}
    {{- $enabled := default "true" (hasKey . "enabled") -}}
    {{- $entrypoints := (list "web" "web-secure") -}}
    {{- if hasKey . "entrypoints" -}}
        {{- $entrypoints := .entrypoints -}}
    {{- end -}}
    {{- if not (kindIs "list" $entrypoints) -}}
        {{- $entrypoints := list $entrypoints -}}
    {{- end -}}
    {{- $domain := trim .domain -}}
traefik.enable: "{{ $enabled }}"
traefik.http.routers.backend.entrypoints: {{ $entrypoints | join "," }}
traefik.http.routers.backend.rule: Host(`{{ $domain }}`)
{{- end }}

{{/*
Creates service labels for load balancer that works as a web
*/}}
{{- define "loadBalancer.labels.forWeb" -}}
{{- $params := dict "entrypoints" "web" "domain" . -}}
{{- template "loadBalancer.labels.generic" $params -}}
{{- end -}}

{{/*
Helper that converts object into base64 string
*/}}
{{- define "object.toBase64String" -}}
{{- toJson . | b64enc -}}
{{- end -}}

{{/*
Helper that outputs correct value when rendering secrets
*/}}
{{- define "helper.secretValue" }}
{{- $tmpVar := . -}}
{{- if eq $tmpVar nil }}{{- $tmpVar = "" -}}{{- end -}}
{{- if eq "$tmpVar" "null" }}{{- $tmpVar = "" -}}{{- end -}}
{{- $tmpVar | toString | b64enc | quote -}}
{{- end -}}

{{- define "helper.trim" -}}
{{- trimSuffix "\n" . | trimSuffix "\r" -}}
{{- end -}}

{{- define "docker.imageUrl" -}}
  {{- $images := .container.images -}}
  {{- $imageDesc := index $images .type -}}
  {{- $imageVersion := printf ":%s" .container.tag -}}
  {{- $diggest := trim $imageDesc.meta.digest -}}
  {{- if and (ne $diggest "") (ne $diggest "none:") (ne .forceTag true) -}}
     {{- $imageVersion = printf "@%s" $diggest -}}
  {{- end -}}
  {{- include "helper.trim" (printf "%s%s" $imageDesc.name $imageVersion) -}}
{{- end -}}
