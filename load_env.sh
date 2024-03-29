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
    "DM_GUNICORN_LOG=0"
    "AFA_CONTAINER_PULL_IMAGE=true"
    "SC_CONF_MQTTCLIENT_QOS=1"
    "SC_CONF_LOGGER_LEVEL=info"
    "SC_CONF_LOGGER_MQTT_LEVEL=warning"
    "SC_CONF_DSROUTER_MAX_COMMAND_AGE=60"
    "SC_CONF_HUB_NAME="
    "SC_OVERRIDE_HUB_ID="
    "SC_CC_LIB_CONNECTOR_HOST="
    "SC_CC_LIB_CONNECTOR_PORT="
    "SC_CC_LIB_CONNECTOR_TLS=True"
    "SC_CC_LIB_CONNECTOR_QOS=2"
    "SC_CC_LIB_CONNECTOR_LOW_LEVEL_LOGGER=False"
    "SC_CC_LIB_API_HUB_ENDPT="
    "SC_CC_LIB_API_DEVICE_ENDPT="
    "SC_CC_LIB_API_AUTH_ENDPT="
    "SC_CC_LIB_CREDENTIALS_USER="
    "SC_CC_LIB_CREDENTIALS_PW="
    "SC_CC_LIB_CREDENTIALS_CLIENT_ID="
    "SC_CC_LIB_DEVICE_ATTRIBUTE_ORIGIN=local-mgw"
    "HBDC_CONF_LOGGER_LEVEL=info"
    "HBDC_CONF_BRIDGE_API_KEY="
    "HBDC_CONF_BRIDGE_ID="
    "HBDC_CONF_DISCOVERY_DEVICE_ID_PREFIX="
    "HBDC_CONF_SENERGY_DT_EXTENDED_COLOR_LIGHT="
    "HBDC_CONF_SENERGY_DT_ON_OFF_PLUG_IN_UNIT="
    "HBDC_CONF_SENERGY_DT_COLOR_LIGHT="
    "HBDC_CONF_SENERGY_DT_COLOR_TEMPERATURE_LIGHT="
    "HBDC_CONF_SENERGY_DT_DIMMABLE_LIGHT="
    "HBDC_CONF_SENERGY_DT_ZLL_PRESENCE="
    "HBDC_CONF_SENERGY_DT_ZLL_SWITCH="
    "BDC_CONF_LOGGER_LEVEL=info"
    "BDC_CONF_DISCOVERY_DEVICE_ID_PREFIX="
    "BDC_CONF_SENERGY_DT_AIR_SENSOR="
    "SMDC_CONF_LOGGER_LEVEL=info"
    "SMDC_CONF_DISCOVERY_DEVICE_ID_PREFIX="
    "SMDC_CONF_DISCOVERY_PORT_FILTER="
    "SMDC_CONF_DISCOVERY_BASE_PATH="
    "SMDC_CONF_SENERGY_DT_LGZXZMF100AC="
    "SMDC_DEVICES_PATH="
    "DDC_CONF_LOGGER_LEVEL=info"
    "DDC_CONF_DISCOVERY_DEVICE_ID_PREFIX="
    "DDC_CONF_ACCOUNT_EMAIL="
    "DDC_CONF_ACCOUNT_PW="
    "DDC_CONF_ACCOUNT_COUNTRY="
    "DDC_CONF_SENERGY_DT_PURE_COOL_LINK="
    "DDC_CONF_DISCOVERY_DEVICE_NAME="
    "DDC_CONF_DISCOVERY_DEVICE_WIFI_SSID="
    "DDC_CONF_DISCOVERY_DEVICE_WIFI_PASSWORD="
    "DDC_CONF_SESSION_LOGGING="
    "ZBDC_MGW_MQTT_BROKER=tcp://message-broker:1883"
    "ZBDC_MGW_MQTT_USER="
    "ZBDC_MGW_MQTT_PW="
    "ZBDC_MGW_MQTT_CLIENT_ID=mgw-zigbee-dc_mgw"
    "ZBDC_ZIGBEE_MQTT_BROKER=tcp://message-broker:1883"
    "ZBDC_ZIGBEE_MQTT_USER="
    "ZBDC_ZIGBEE_MQTT_PW="
    "ZBDC_ZIGBEE_MQTT_CLIENT_ID=mgw-zigbee-dc_zigbee"
    "ZBDC_AUTH_ENDPOINT=https://auth.senergy.infai.org"
    "ZBDC_PERMISSIONS_SEARCH_URL=https://api.senergy.infai.org/permissions/query"
    "ZBDC_DEVICE_ID_PREFIX=zigbee:"
    "ZBDC_ZIGBEE_MQTT_TOPIC_PREFIX=zigbee2mqtt/"
    "Z2M_DEVICES_PATH="
    "Z2M_IMAGE=robertslando/zwave2mqtt:latest"
    #"Z2M_IMAGE=zwavejs/zwavejs2mqtt:latest"
    "ZDC_ZWAVE_CONTROLLER=zwave2mqtt"
    #"ZDC_ZWAVE_CONTROLLER=zwavejs2mqtt"
    "ZDC_DEVICE_ID_PREFIX="
    "ZDC_DEBUG=false"
    "ZDC_UPDATE_PERIOD=15m"
    "ZDC_DELETE_MISSING_DEVICES=true"
    "ZDC_DELETE_HUSKS=false"
    "ZDC_ZWAVE_MQTT_BROKER=tcp://message-broker:1883"
    "ZDC_ZWAVE_MQTT_USER="
    "ZDC_ZWAVE_MQTT_PW="
    "ZDC_ZWAVE_MQTT_CLIENT_ID=mgw-zwave-dc_zwave"
    "ZDC_ZWAVE_VALUE_EVENT_TOPIC=zwave2mqtt/#"
    "ZDC_ZWAVE_MQTT_API_TOPIC=zwave2mqtt/_CLIENTS/ZWAVE_GATEWAY-SENERGY/api"
    "ZDC_ZWAVE_NETWORK_EVENTS_TOPIC=zwave2mqtt/_EVENTS/ZWAVE_GATEWAY-SENERGY"
    "ZDC_MGW_MQTT_BROKER=tcp://message-broker:1883"
    "ZDC_MGW_MQTT_PW="
    "ZDC_MGW_MQTT_CLIENT_ID=mgw-zwave-dc_mgw"
    "ZDC_EVENTS_FOR_UNREGISTERED_DEVICES=false"
    "ZDC_CREATE_MISSING_DEVICE_TYPES=false"
    "CDB_POSTGRES_USER=camunda"
    "CDB_POSTGRES_PASSWORD="
    "NOTI_DEBUG=false"
    "NOTI_NOTIFICATION_URL="
    "NOTI_AUTH_ENDPOINT="
    "NOTI_AUTH_USER_NAME="
    "NOTI_AUTH_PASSWORD="
    "ETW_COMPLETION_STRATEGY=pessimistic"
    "ETW_CAMUNDA_TOPIC=pessimistic"
    "ETW_AUTH_ENDPOINT="
    "ETW_AUTH_USER_NAME="
    "ETW_AUTH_PASSWORD="
    "ETW_DEVICE_REPO_URL="
    "ETW_PERMISSIONS_SEARCH_URL=https://api.senergy.infai.org/permissions/query"
    "ETW_DEBUG=false"
    "SBB_CONF_LOGGER_LEVEL=info"
    "SBB_CONF_DISCOVERY_SCAN_DELAY=1800"
    "SBB_CONF_DISCOVERY_DEVICE_ID_PREFIX=switchbotbluetooth-"
    "SBB_CONF_DISCOVERY_COMMAND_RETRIES=2"
    "SBB_CONF_DISCOVERY_ADAPTER=hci0"
    "SBB_CONF_CLIENT_KEEPALIVE=60"
    "KASA_CONF_LOGGER_LEVEL=info"
    "KASA_CONF_DISCOVERY_SCAN_DELAY=1800"
    "KASA_CONF_DISCOVERY_DEVICE_ID_PREFIX=kasa-"
    "KASA_CONF_DISCOVERY_TIMEOUT=2"
    "KASA_CONF_DISCOVERY_SUBNET=${MGW_HOST_IP}/24"
    "KASA_CONF_DISCOVERY_IP_LIST="
    "KASA_CONF_DISCOVERY_NUM_WORKERS=0"
    "KASA_CONF_CLIENT_KEEPALIVE=30"
    "KASA_CONF_SENERGY_EVENTS_STATUS_SECONDS=600"
    "KASA_CONF_SENERGY_EVENTS_ENERGY_SECONDS=30"
    "MQTT_DC_CONF_MQTT_BROKER=tcp://message-broker:1883"
    "MQTT_DC_CONF_MQTT_USER="
    "MQTT_DC_CONF_MQTT_PW="
    "MQTT_DC_CONF_MQTT_CMD_CLIENT_ID=mgw-mqtt-dc-cmd"
    "MQTT_DC_CONF_MQTT_EVENT_CLIENT_ID=mgw-mqtt-dc-event"
    "MQTT_DC_CONF_GENERATOR_USE=true"
    "MQTT_DC_CONF_GENERATOR_AUTH_ENDPOINT=https://auth.senergy.infai.org"
    "MQTT_DC_CONF_GENERATOR_PERMISSION_SEARCH_URL=https://api.senergy.infai.org/permissions/query"
    "MQTT_DC_CONF_GENERATOR_DEVICE_REPOSITORY_URL=https://api.senergy.infai.org/device-repository"
    "MQTT_DC_CONF_GENERATOR_TRUNCATE_DEVICE_PREFIX="
    "MQTT_DC_CONF_UPDATE_PERIOD=5m"
    "SENEC_CONF_LOGGER_LEVEL=info"
    "SENEC_CONF_DISCOVERY_SCAN_DELAY=3600"
    "SENEC_CONF_DISCOVERY_DEVICE_ID_PREFIX=senec-"
    "SENEC_CONF_DISCOVERY_TIMEOUT=2"
    "SENEC_CONF_DISCOVERY_SUBNET=${MGW_HOST_IP}/24"
    "SENEC_CONF_DISCOVERY_IP_LIST="
    "SENEC_CONF_DISCOVERY_NUM_WORKERS=0"
    "SENEC_CONF_CLIENT_KEEPALIVE=30"
    "SENEC_CONF_SENERGY_EVENTS_ENERGY_SECONDS=10"
    "MADOKA_INTERVAL=15"
    "MADOKA_MAC=00:00:00:00:00:00"
    "MADOKA_BT_ADAPTER=hci0"
    "TESLA_CONF_LOGGER_LEVEL=info"
    "TESLA_CONF_DISCOVERY_SCAN_DELAY=86400"
    "TESLA_CONF_SENERGY_EVENTS_GET_VEHICLE_DATA_SECONDS=3600"
    "TESLA_CONF_TESLA_EMAIL="
    "TESLA_CONF_TESLA_REFRESHTOKEN="
    "ADVR_MGW_NAME_PREFIX="
    "ADVR_MGW_SERIAL="
    "SOLMATE_DISCOVERY_IPS="
    "SOLMATE_CONF_LOGGER_LEVEL=info"
    "SOLMATE_EVENTS_LIVE_VALUES_SECONDS=5"
    "SOLMATE_EVENTS_INJECTION_SETTINGS_SECONDS=15"
    "SSH_HOSTS="
    "SSH_USERS="
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
    getIP > .host_ip
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
