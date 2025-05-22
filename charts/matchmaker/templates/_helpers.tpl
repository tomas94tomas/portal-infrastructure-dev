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

{{/*
Helper that converts object into base64 string
*/}}
{{- define "object.toBase64String" -}}
{{- toJson . | b64enc -}}
{{- end -}}
