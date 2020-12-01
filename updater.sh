#!/bin/bash

#   Copyright 2019 InfAI (CC SES)
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


# Log levels:
# debug   = 0
# info    = 1
# warning = 2
# error   = 3


log_lvl=("debug" "info" "warning" "error")

current_date="$(date +"%m-%d-%Y")"


installUpdaterService() {
    echo "creating systemd service ..."
    echo "[Unit]
After=docker.service

[Service]
ExecStart=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/updater.sh
Restart=always

[Install]
WantedBy=default.target
" > /etc/systemd/system/cc-hub-updater.service
    if [[ $? -eq 0 ]]; then
        if chmod 664 /etc/systemd/system/cc-hub-updater.service; then
            echo "successfully created service"
            echo "reloading daemon ..."
            if systemctl daemon-reload; then
                echo "enabling systemd service ..."
                if systemctl enable cc-hub-updater.service; then
                    echo "successfully enabled service"
                    return 0
                else
                    echo "enabling service failed"
                fi
            else
                echo "reloading daemon failed"
            fi
        else
            echo "setting premissions failed"
        fi
    else
        echo "creating service failed"
    fi
    return 1
}


log() {
    if [ $1 -lt $CC_HUB_UPDATER_LOG_LVL ]; then
        return 0
    fi
    logger=""
    if ! [[ -z "${log_lvl[$1]}" ]]; then
        logger=" [${log_lvl[$1]}]"
    fi
    first=1
    while read -r line; do
        if [ "$first" -eq "1" ]; then
            echo "[$(date +"%m.%d.%Y %I:%M:%S %p")]$logger $line" >> $CC_HUB_PATH/logs/updater.log 2>&1
            first=0
        else
            echo "$line" >> $CC_HUB_PATH/logs/updater.log 2>&1
        fi
    done
}


rotateLog() {
    if [ "$current_date" != "$(date +"%m-%d-%Y")" ]; then
        cp logs/updater.log logs/updater-$current_date.log
        truncate -s 0 logs/updater.log
        current_date="$(date +"%m-%d-%Y")"
    fi
}


updateSelf() {
    echo "(hub-updater) checking for updates ..." | log 1
    update_result=$(git remote update 3>&1 1>&2 2>&3 >/dev/null)
    if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
        status_result=$(git status)
        if [[ $status_result = *"behind"* ]]; then
            echo "(hub-updater) downloading and applying updates ..." | log 1
            pull_result=$(git pull 3>&1 1>&2 2>&3 >/dev/null)
            if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                echo "(hub-updater) $(./load_env.sh update)" | log 1
                echo "(hub-updater) update success" | log 1
                return 0
            else
                echo "(hub-updater) $pull_result" | log 3
                return 1
            fi
        else
            echo "(hub-updater) up-to-date" | log 1
            return 2
        fi
    else
        echo "(hub-updater) checking for updates - failed" | log 3
        return 1
    fi
}


pullImage() {
    docker pull "$1" 2>&1 | log 0
    return ${PIPESTATUS[0]}
}


containerRunningState() {
    status=$(curl -G --silent --unix-socket "/var/run/docker.sock" --data-urlencode 'filters={"name": ["'$1'"]}' "http:/v1.40/containers/json" | jq -r '.[0].State')
    if [[ $status = "running" ]]; then
        return 0
    fi
    return 1
}


redeployContainer() {
    if containerRunningState "$1"; then
        docker-compose --no-ansi up -d "$1" 2>&1 | log 0
        return ${PIPESTATUS[0]}
    else
        docker-compose --no-ansi up --no-start "$1" 2>&1 | log 0
        return ${PIPESTATUS[0]}
    fi
    return 1
}


getToken() {
    curl --silent "$CC_DOCKER_HUB_AUTH?scope=repository:$1:pull&service=registry.docker.io" | jq -r '.token'
}


updateHub() {
    if curl --silent --fail --unix-socket "/var/run/docker.sock" "http:/v1.40/info" > /dev/null; then
        echo "(hub-updater) checking for images to update ..." | log 1
        images=$(curl --silent --unix-socket "/var/run/docker.sock" "http:/v1.40/images/json")
        num=$(echo $images | jq -r 'length')
        for ((i=0; i<=$num-1; i++)); do
            img_info=$(echo $images | jq -r ".[$i].RepoTags[0]")
            img_hash=$(echo $images | jq -r ".[$i].Id")
            img=$(echo $img_info | cut -d':' -f1)
            img_name=$(echo $img_info | cut -d'/' -f2 | cut -d':' -f1)
            img_tag=$(echo $img_info | cut -d':' -f2)
            if grep -q "$img" $CC_HUB_PATH/docker-compose.yml; then
                if curl --silent --fail "$CC_DOCKER_HUB_API" > /dev/null; then
                    echo "($img_name) checking for updates ..." | log 1
                    token=$(getToken $img)
                    remote_img_hash=$(curl --silent --header "Accept: application/vnd.docker.distribution.manifest.v2+json" --header "Authorization: Bearer $token" "$CC_DOCKER_HUB_API/$img/manifests/$img_tag" | jq -r '.config.digest')
                    if ! [[ $remote_img_hash == "null" ]]; then
                        if ! [ "$img_hash" = "$remote_img_hash" ]; then
                            echo "($img_name) pulling new image ..." | log 1
                            if pullImage "$img_info"; then
                                echo "($img_name) pulling new image successful" | log 1
                                echo "($img_name) redeploying container ..." | log 1
                                if redeployContainer $img_name; then
                                    echo "($img_name) redeploying container successful" | log 1
                                    docker image prune -f > /dev/null 2>&1
                                else
                                    echo "($img_name) redeploying container failed" | log 3
                                fi
                            else
                                echo "($img_name) pulling new image failed" | log 3
                            fi
                        else
                            echo "($img_name) up-to-date" | log 1
                        fi
                    else
                      echo "($img_name) retrieving remote hash failed" | log 3
                    fi
                else
                    echo "($img_name) can't reach docker hub '$CC_DOCKER_HUB_API'" | log 3
                fi
            fi
        done
        return 0
    else
      echo "(hub-updater) docker engine not running" | log 3
      return 1
    fi
}


initCheck() {
    if [ ! -d "logs" ]; then
        mkdir logs
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo "dependency 'jq' not installed" | log 3
        exit 1
    fi
    if ! command -v truncate >/dev/null 2>&1; then
        echo "dependency 'truncate' not installed" | log 3
        exit 1
    fi
    if ! command -v ip >/dev/null 2>&1; then
        echo "dependency 'ip' not installed"
        exit 1
    fi
}


strtMsg() {
    echo "***************** starting client-connector-hub-updater *****************" | log 4
    echo "running in: '$CC_HUB_PATH'" | log 4
    echo "check every: '$CC_HUB_UPDATER_DELAY' seconds" | log 4
    echo "environment: '$CC_HUB_ENVIRONMENT'" | log 4
    echo "log level: '${log_lvl[$CC_HUB_UPDATER_LOG_LVL]}'" | log 4
    echo "PID: '$$'" | log 4
}


cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -z "$1" ]]; then
    source ./load_env.sh
    initCheck
    strtMsg
    while true; do
        sleep $CC_HUB_UPDATER_DELAY
        rotateLog
        if updateSelf; then
            echo "(hub-updater) restarting ..." | log 1
            break
        fi
        updateHub
    done
    exit 0
else
    if [[ $1 == "install" ]]; then
        echo "installing client-connector-hub-updater ..."
        ./load_env.sh install
        if installUpdaterService; then
            echo "installation successful"
            exit 0
        else
            echo "installation failed"
            exit 1
        fi
    else
        echo "unknown argument: '$1'"
        exit 1
    fi
fi
