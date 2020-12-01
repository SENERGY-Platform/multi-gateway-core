#!/bin/bash

#   Copyright 2020 InfAI (CC SES)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


core_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

conf_file="core.conf"

conf_vars=(
    "MGW_ENVIRONMENT=prod"
    "MGW_DOCKER_HUB_API=https://registry-1.docker.io/v2"
    "MGW_DOCKER_HUB_AUTH=https://auth.docker.io/token"
    "MGW_UPDATER_DELAY=600"
    "MGW_UPDATER_LOG_LVL=1"
    "SCS_CONNECTORCONF_CONNECTOR=host:localhost;port:1883;tls:False;enable_fog:True"
    "SCS_CONNECTORCONF_AUTH=host:localhost;path:auth/realms/master/protocol/openid-connect/token;tls:True;id:client-id"
    "SCS_CONNECTORCONF_CREDENTIALS=user:user;pw:pw"
    "SCS_CONNECTORCONF_HUB=name:multi-hub"
    "SCS_CONNECTORCONF_API=host:localhost;hub_endpt:device-manager/hubs;device_endpt:device-manager/local-devices;tls:False"
    "MGW_DOCKER_SUBNET=10.40.0.0/16"
    "GC_GOSUND_PREFIX="
    "GC_DEVICES_TYPE="
)

env_vars=(
    "MGW_CORE_PATH=$core_dir"
    "MGW_CORE_DIR_NAME=${core_dir##*/}"
    "MGW_HOST_IP=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)"
)


initConf() {
    echo "creating $conf_file ..."
    truncate -s 0 $core_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        echo "$var" >> $core_dir/$conf_file
    done
}


updateConf() {
    echo "updating $conf_file ..."
    truncate -s 0 $core_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        var_name=$(echo "$var" | cut -d'=' -f1)
        if [[ -z "${!var_name}" ]]; then
            echo "$var" >> $core_dir/$conf_file
        else
            echo "$var_name=${!var_name}" >> $core_dir/$conf_file
        fi
    done
}


loadConf() {
    while IFS= read -r line; do
        export "$line"
    done < $core_dir/$conf_file
}


loadEnv() {
  for var in "${env_vars[@]}"; do
      export "$var"
  done
}


if [[ -z "$1" ]]; then
    loadConf
    loadEnv
else
    case "$1" in
        install)
            initConf
            exit 0
            ;;
        update)
            loadConf
            updateConf
            exit 0
            ;;
        *)
            echo "unknown argument: '$1'"
            exit 1
    esac
fi
