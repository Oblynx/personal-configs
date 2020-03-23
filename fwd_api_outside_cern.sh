#!/bin/bash

# Needs sudo

authzapidev_name="authorization-service-api-dev.web.cern.ch"
authzapidev_fwdIP='173.148.52.184'
authzapidev_localport=20156
kcdev_name="keycloak-dev.cern.ch"
kcdev_fwdIP='173.148.52.185'
kcdev_localport=20157

fwd_api() {
  name="$1"
  fwdIP="$2"
  localport="$3"

  #1. /etc/hosts DNS alias: `authorization-service-api-dev.web.cern.ch -> <random IP X>`
  sudo bash -c "echo \"$fwdIP $name\" >> /etc/hosts"
  #2. iptables fwd: `X:443 -> localhost:20500`
  sudo iptables -t nat -I OUTPUT --dst "$fwdIP" -p tcp --dport 443 -j REDIRECT --to-ports "$localport"
  #3. ssh -L: `localhost:20500 -> authorization-service-api-dev.web.cern.ch:443` over aiadm
  ssh -NnfL "$localport:$name:443" aiadm
}

fwd_api "$authzapidev_name" "$authzapidev_fwdIP" "$authzapidev_localport"
fwd_api "$kcdev_name" "$kcdev_fwdIP" "$kcdev_localport"
