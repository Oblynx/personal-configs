#!/bin/bash

# Authz API QA
authzapiqa_name="authorization-service-api-qa.web.cern.ch"
# Keycloak
kcqa_name="keycloak-qa.cern.ch"
# CERN helm chart registry
registry_name="registry.cern.ch"

fwd_api_outside_cern.sh "$authzapiqa_name"
fwd_api_outside_cern.sh "$kcqa_name"
fwd_api_outside_cern.sh "$registry_name"
