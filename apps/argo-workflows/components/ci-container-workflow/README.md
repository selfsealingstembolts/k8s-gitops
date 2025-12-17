This workflow builds an OCI container from a git repo using kaniko. It is designed to be used with an Argo Events webhook sensor, triggered by a git event. Examples of these sensors can be found [here](https://gitlab.example.com/k8s-gitops/apps/argo-events/components). It expects to find a configuration file in the same directory as the Dockerfile (or Containerfile), by default named `.argo-ci.yaml`. An example of this file is as follows:

``` yaml
name: harbor.k8s.example.com/local/renovate

# renovate: datasource=docker depName=ghcr.io/renovatebot/renovate versioning=docker
tags:
  - 37.210.0

# relative path to build context
# only required if differs from directory containing .argo-ci.yaml
context: ../

# relative path to dockerfile
# only required if differs from directory containing .argo-cd.yaml
dockerfile: Containerfile

# key: value list of additional build args
args:
  REMOTE_CA: "http://ipa0.idm.example.com/ipa/config/ca.crt"

# metadata labels
# equivalent to LABEL in Dockerfile
labels:
  org.opencontainers.image.title: "renovate"
  ## Human-readable description of the software packaged in the image
  org.opencontainers.image.description: "Automated dependency updates. Multi-platform and multi-language."
  ## License(s) under which contained software is distributed
  org.opencontainers.image.licenses: "AGPL-3.0-only"
  ## URL to find more information on the image
  org.opencontainers.image.url: "https://github.com/renovatebot/renovate"
  # renovate: datasource=docker depName=ghcr.io/renovatebot/renovate versioning=docker
  org.opencontainers.image.version: "37.210.0"
  
# relative path to files to monitor for changes
# any modifications to these files will trigger a build
# by default, the directory containing .argo-cd.yaml will automatically be monitored
triggers:
  - ../common
  
```

