#!/bin/bash

# Authz API dev
authzapidev_name="authorization-service-api-dev.web.cern.ch"
# Keycloak
kcdev_name="keycloak-dev.cern.ch"
# CERN helm chart registry
registry_name="registry.cern.ch"

fwd_api_outside_cern.sh "$authzapidev_name"
fwd_api_outside_cern.sh "$kcdev_name"
fwd_api_outside_cern.sh "$registry_name"
