#!/bin/bash
# Needs sudo
# Forward an HTTP API through a CERN lxplus tunnel

# Parameters
base_fwdIP='173.148.52.0'
fwdIP_file='/tmp/fwdIPs'
base_localport=20156
localport_file='/tmp/fwdLocalports'

# Given a fwdIP, produce the next one
next_fwdIP() {
  nextIP=$(echo $1| cut -d. -f-3).$(( $(echo $1| cut -d. -f4)+1 ))
  echo "$nextIP" >> "$fwdIP_file"
  echo "$nextIP"
}
# Produce the last used fwdIP
lastFwdIP() {
  [[ -f "$fwdIP_file" ]] && ip=$(tail -n1 "$fwdIP_file")
  [[ -z "$ip" ]] && ip=$base_fwdIP
  echo "$ip"
}
# Produce the last used localport
lastLocalport() {
  [[ -f "$localport_file" ]] && localport=$(tail -n1 "$localport_file")
  [[ "$localport" < "$base_localport" ]] && localport="$base_localport"
  echo "$localport"
}

# Forward an HTTP API through a local tunnel
fwd_api() {
  hostname="$1"
  port="$2"

  fwdIP=$(grep -he $hostname /etc/hosts | head -n1 | cut -d' ' -f1)
  [[ -z "$fwdIP" ]] && {
    fwdIP=$(next_fwdIP "$(lastFwdIP)")
    #1. /etc/hosts DNS alias: `authorization-service-api-dev.web.cern.ch -> <random IP X>`
    sudo bash -c "echo \"$fwdIP $hostname\" >> /etc/hosts"
  }

  localport=$(( $(lastLocalport)+1 ))
  echo "$localport" >> "$localport_file"

  #2. iptables fwd: `X:443 -> localhost:20500`
  sudo iptables -t nat -I OUTPUT --dst "$fwdIP" -p tcp --dport "$port" -j REDIRECT --to-ports "$localport"
  #3. ssh -L: `localhost:20500 -> authorization-service-api-dev.web.cern.ch:443` over lxplus
  ssh -NnfL "$localport:$hostname:$port" lxplus
}

usage() {
  echo "Usage: $0 <hostname-to-fwd>"
  echo "eg: $0 registry.cern.ch"
  exit 1
}

[[ -z "$1" ]] && usage

# If we are given a hostname with a port, reuse that port. Otherwise, default port to 443
hostname=$(echo $1 | cut -d: -f1)
port=$(echo $1 | cut -s -d: -f2)
port=${port:-443}

# If we can already make https requests, there is nothing more to do
curl -m3 --insecure "https://${hostname}:${port}" &> /dev/null ||
  fwd_api "$hostname" "$port"
