## mulit-gateway-core

This repository contains the [core files](#core-files) required to deploy, update and configure the MGW (Multi-GateWay) [services](#mgw-services).

---

#### MGW Services

- [device-manager](https://github.com/SENERGY-Platform/device-management-service)
- [senergy-connector](https://github.com/SENERGY-Platform/senergy-connector)
- [gosund-connector](https://github.com/SENERGY-Platform/gosund-connector)
- [analytics-fog-master](https://github.com/SENERGY-Platform/analytics-fog-master)
- [analytics-fog-agent](https://github.com/SENERGY-Platform/analytics-fog-agent)
- [z-way-cc](https://github.com/SENERGY-Platform/zway-connector)
- [eclipse-mosquitto](https://mosquitto.org/)

---


#### Core Files

    multi-gateway-core/
        |
        |--- docker-compose.yml
        |
        |--- updater.sh
        |
        |--- load_env.sh
        |
        |--- core.conf
        |
        |--- logs/
        |        |
        |        |--- updater.log
        |        |
        |        |--- ...
        |
        |--- .eclipse-mosquitto-config/
                 |
                 |--- certs/
                 |        |
                 |        |--- ...
                 |
                 |--- gen_certs.sh
                 |
                 |--- mosquitto.conf

---

#### MGW Core Installation

Requirements:
 - bash
 - git
 - docker
 - docker-compose
 - systemd
 - jq
 - truncate
 - ip
 - openssl

Clone this repository to a preferred location (for example `/opt/multi-gateway-core`):

    git clone https://github.com/SENERGY-Platform/multi-gateway-core.git

Navigate to the repository you just created and choose **one** of the options below.

 - Install automatic core updates and config loader:
	 - With root privileges run `./updater.sh install` and afterwards issue `systemctl start mgw-updater.service` or reboot the system.
 - Install config loader only:
	 - With root privileges run `./load_env.sh install`.

---

#### Configuration

The core updater and MGW [services](#mgw-services) can be configured via the `core.conf` file:

 - `MGW_DOCKER_SOCKET` docker socket path.
 - `MGW_ENVIRONMENT` set to either `dev` for developemnt branch or `prod` for stable branch.
 - `MGW_UPDATER_DELAY` determine how often (in seconds) the core updater checks for updates and installs updates.
 - `MGW_UPDATER_LOG_LVL` set logging level for core updater. (`0`: debug, `1`: info, `2`: warning, `3`: error)
 - `MGW_DOCKER_SUBNET` define the subnet of the docker-network. All MGW [services](#mgw-services) reside in this network. (Services must be redeployed after this.)

Restart the mgw-updater.service for changes to take affect.

---

#### Deploy MGW Services

To deploy the MGW [services](#mgw-services) go to the [core installation dictionary](#mgw-core-installation) and with root privileges issue the following command:

    ./updater.sh deploy

To deploy a single service use the above command and replace `####` with the name of a [service](#mgw-services):

    ./updater.sh deploy ####

---

#### Generate certificates and keys

Navigate to the [core installation dictionary](#mgw-core-installation) and enter the `eclipse-mosquitto-config` dictionary. Execute `./gen_certs.sh` and enter your details when prompted.
