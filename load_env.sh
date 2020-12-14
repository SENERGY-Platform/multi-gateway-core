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
    "MGW_NIC=eth0"
    "MGW_DOCKER_SOCKET=/var/run/docker.sock"
    "MGW_DOCKER_SUBNET=10.40.0.0/16"
    "MGW_ENVIRONMENT=prod"
    "MGW_UPDATER_DELAY=600"
    "MGW_UPDATER_LOG_LVL=1"
    "DM_CONF_LOGGER_LEVEL=info"
    "AFA_CONTAINER_PULL_IMAGE=true"
    "SC_CONF_LOGGER_LEVEL=info"
    "SC_CONF_DSROUTER_MAX_COMMAND_AGE=60"
    "SC_CONNECTORCONF_CONNECTOR=host:localhost;port:1883;tls:False;enable_fog:True"
    "SC_CONNECTORCONF_AUTH=host:localhost;path:auth/realms/master/protocol/openid-connect/token;tls:True;id:client-id"
    "SC_CONNECTORCONF_CREDENTIALS=user:user;pw:pw"
    "SC_CONNECTORCONF_HUB=name:multi-gateway"
    "SC_CONNECTORCONF_API=host:localhost;hub_endpt:device-manager/hubs;device_endpt:device-manager/local-devices;tls:False"
    "SC_CONNECTORCONF_LOGGER=level:info"
    "HBDC_CONF_LOGGER_LEVEL=info"
    "HBDC_CONF_BRIDGE_API_KEY="
    "HBDC_CONF_BRIDGE_ID="
    "HBDC_CONF_DISCOVERY_DEVICE_ID_PREFIX="
    "HBDC_CONF_SENERGY_DT_EXTENDED_COLOR_LIGHT="
    "HBDC_CONF_SENERGY_DT_ON_OFF_PLUG_IN_UNIT="
    "HBDC_CONF_SENERGY_DT_COLOR_LIGHT="
    "BDC_CONF_LOGGER_LEVEL=info"
    "BDC_CONF_API_AIR_SENSOR_STATE="
    "BDC_CONF_API_AIR_SENSOR_DEVICE="
    "BDC_CONF_DISCOVERY_REMOTE_HOST="
    "BDC_CONF_DISCOVERY_DEVICE_ID_PREFIX="
    "BDC_CONF_SENERGY_DT_AIR_SENSOR="
    "GC_CONF_LOGGER_LEVEL=info"
    "GC_CONF_DEVICES_TYPE="
    "GC_CONF_DEVICES_LW_TOPIC=LWT"
    "GC_GOSUND_PREFIX="
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


getIP() {
    plattform="$(uname -s)"
    case "${plattform}" in
        Linux*)
            ip -o -4 addr list "$MGW_NIC" | awk '{print $4}' | cut -d/ -f1
        ;;
        Darwin*)
            ip -4 addr list "$MGW_NIC" | awk '/inet/ {print $2}' | cut -d/ -f1
        ;;
    esac
}


loadEnv() {
  env_vars=(
      "MGW_CORE_PATH=$core_dir"
      "MGW_CORE_DIR_NAME=${core_dir##*/}"
      "MGW_HOST_IP=$(getIP)"
  )
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
