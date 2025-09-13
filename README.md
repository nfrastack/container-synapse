# nfrastack/container-synapse

## About

This repository will build a container with [Synapse] (https://matrix.oprg/docs/projects/server/synapse), A Matrix.org Homeserver.

## Maintainer

* [Nfrastack](https://www.nfrastack.com)

## Table of Contents


* [About](#about)
* [Maintainer](#maintainer)
* [Table of Contents](#table-of-contents)
* [Installation](#installation)
  * [Prebuilt Images](#prebuilt-images)
  * [Quick Start](#quick-start)
  * [Persistent Storage](#persistent-storage)
* [Configuration](#configuration)
  * [Environment Variables](#environment-variables)
    * [Base Images used](#base-images-used)
    * [Core Configuration](#core-configuration)
  * [Users and Groups](#users-and-groups)
  * [Networking](#networking)
* [Maintenance](#maintenance)
  * [Shell Access](#shell-access)
* [Support & Maintenance](#support--maintenance)
* [License](#license)

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-synapse/pkgs/container/container-synapse) and [Docker Hub](https://hub.docker.com/r/nfrastack/synapse).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-synapse:(image_tag)
docker.io/nfrastack/synapse:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>`

Example:

`ghcr.io/nfrastack/container-synapse:latest` or

`ghcr.io/nfrastack/container-synapse:1.0` or

* `latest` will be the most recent commit
* An otpional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
* If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

* Map persistent storage for access to configuration and data files for backup.
* Set various environment variables to understand the capabilities of this image.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory | Description |
| --------- | ----------- |
| `/data/certs/`    | Signing Keys        |
| `/data/config`    | Configuration Files |
| `/data/media`     | Media / Assets      |
| `/data/templates` | Email Templates     |
| `/data/uploads`   | Uploaded Assets     |
| `/logs`           | Log files           |

## Configuration

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                   | Description      |
| ------------------------------------------------------- | ---------------- |
| [OS Base](https://github.com/nfrastack/container-base/) | Base Image       |
| [Nginx](https://github.com/nfrastack/container-nginx/)  | Web Server Image |

Below is the complete list of available options that can be used to customize your installation.

* Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Container Options

| Variable             | Description                                          | Default                  |
| -------------------- | ---------------------------------------------------- | ------------------------ |
| `CERT_PATH`          | Signing Key Path                                     | `${DATA_PATH}/certs/`    |
| `CONFIG_FILE`        | Configuration File                                   | `homeserver.yaml`        |
| `CONFIG_PATH`        | Configuration File path                              | `${DATA_PATH}/config/`   |
| `DATA_PATH`          | Data Path                                            | `/data/`                 |
| `LOG_FORMAT`         | What format of logs `STANDARD` or `JSON`             | `STANDARD`               |
| `LOG_FORMAT_CONSOLE` | What format of logs `STANDARD` or `JSON` for console | `${LOG_FORMAT}`          |
| `LOG_FORMAT_FILE`    | What format of logs `STANDARD` or `JSON` for file    | `${LOG_FORMAT}`          |
| `LOG_PATH`           | Log file path                                        | `/logs/`                 |
| `LOG_TYPE`           | How to display logs `FILE`,`CONSOLE` or `BOTH`       | `FILE`                   |
| `MEDIA_PATH`         | Media / Assets path                                  | `${DATA_PATH}/media`     |
| `SETUP_MODE`         | Update configuration based on environment variables  | `AUTO`                   |
| `TEMPLATE_PATH`      | Email Templates                                      | `${DATA_PATH}/templates` |
| `UPLOAD_PATH`        | Uploads Path                                         | `${DATA_PATH}/uploads`   |

#### Application Options

| Variable                                | Description                           | Default                  | `_FILE` |
| --------------------------------------- | ------------------------------------- | ------------------------ | ------- |
| `CREATE_ADMIN_USER`                     | Create Admin User on Startup          | `TRUE`                   |         |
| `ADMIN_PASS`                            | Admin Password                        | `tiredofit`              | x       |
| `ADMIN_USER`                            | Admin User Name                       | `synapse`                | x       |
| `CONTACT_ADMIN_EMAIL`                   | Admin Contact Email                   | `admin@example.com`      |         |
| `ENABLE_HTTP`                           | Enable HTTP Listeners                 | `TRUE`                   |         |
| `ENABLE_METRICS`                        | Enable Metrics Listeners              | `TRUE`                   |         |
| `HTTP_ENABLE_COMPRESSION`               | Enable Compression                    | `TRUE`                   |         |
| `HTTP_ENABLE_TLS`                       | Enable TLS Services                   | `FALSE`                  |         |
| `HTTP_ENABLE_X_FORWARDED`               |                                       | `TRUE`                   |         |
| `HTTP_LISTEN_IP`                        | HTTP Listen Port                      | `0.0.0.0`                |         |
| `HTTP_LISTEN_PORT`                      | HTTP Listen Port                      | `8008`                   |         |
| `HTTP_MODE`                             | What resources to offer               | `client,federation`      |         |
| `LOG_BUFFER`                            |                                       | `10`                     |         |
| `LOG_FILE`                              | Log File                              | `homeserver.log`         |         |
| `LOG_INTERVAL_FLUSH_FORCE`              |                                       | `5`                      |         |
| `LOG_LEVEL_FLUSH`                       |                                       | `30`                     |         |
| `LOG_LEVEL_LDAP_AUTH_PROVIDER`          | Log LDAP Auth Provider Level          | `${LOG_LEVEL}`           |         |
| `LOG_LEVEL_LDAP`                        | Log LDAP Level                        | `${LOG_LEVEL}`           |         |
| `LOG_LEVEL_SHARED_SECRET_AUTHENTICATOR` | Log Shared Secret Authenticator Level | `${LOG_LEVEL}`           |         |
| `LOG_LEVEL_SQL`                         | Log SQL Level                         | `${LOG_LEVEL}`           |         |
| `LOG_LEVEL`                             | Log Level                             | `INFO`                   |         |
| `METRICS_LISTEN_IP`                     | Metrics Listen IP                     | `127.0.0.1`              |         |
| `METRICS_LISTEN_PORT`                   | HTTP Listen Port                      | `8009`                   |         |
| `SECRET_FORM`                           | Form secret                           | (autogenerated)          | x       |
| `SECRET_MACAROON`                       | Macaroon secret                       | (autogenerated)          | x       |
| `SECRET_REGISTRATION`                   | Registration secret                   | (autogenerated)          | x       |
| `SERVER_NAME`                           | Server name eg `example.com`          |                          |         |
| `SERVER_URL`                            | Server URL eg `https://example.com`   | `https://${SERVER_NAME}` |         |

#### Database Options

| Variable                    | Description                           | Default                | `_FILE` |
| --------------------------- | ------------------------------------- | ---------------------- | ------- |
| `DB_SQLITE_NAME`            | (sqlite) Database name                | `homeserver.db`        |         |
| `DB_SQLITE_PATH`            | (sqlite) Database Path                | `${DATA_PATH}/sqlite/` |         |
| `DB_POOL_MAX`               | (postgres)                            | `10`                   |         |
| `DB_POOL_MIN`               | (postgres)                            | `5`                    |         |
| `DB_TRANSACTION_LIMIT`      | (postgres)                            | `10000`                |         |
| `DB_HOST`                   | (postgres) Postgresql Hostname        |                        | x       |
| `DB_KEEP_ALIVE_INTERVAL_MS` | (postgres) Keep alive in milliseconds | `30000`                |         |
| `DB_NAME`                   | (postgres)  Postgresql Name           |                        | x       |
| `DB_PASS`                   | (postgres)  Postgresql Password       |                        | x       |
| `DB_PORT`                   | (postgres)  Postgresql Port           | `5432`                 | x       |
| `DB_TYPE`                   | Database type `postgres` or `sqlite`  | `POSTGRES`             |         |
| `DB_USER`                   | (postgres)  Postgresql User           |                        | x       |

#### Media Options

| Variable                   | Description                      | Default |
| -------------------------- | -------------------------------- | ------- |
| `ENABLE_MEDIA_REPO`        | Enable inbuilt Media Repository  | `TRUE`  |
| `MEDIA_DYNAMIC_THUMBNAILS` | Enable Dynamic Thumbnails        | `TRUE`  |
| `MEDIA_MAX_UPLOAD_SIZE`    | Maximum upload size              | `50M`   |
| `MEDIA_MAX_IMAGE_PIXELS`   | Max image pixels                 | `32M`   |
| `MEDIA_MAX_SPIDER_SIZE`    | Maximum Spider Size              | `10m`   |
| `MEDIA_RETENTION_LOCAL`    | Retain Local media for how long  | `90d`   |
| `MEDIA_RETENTION_REMOTE`   | Retain remote media for how long | `14d`   |

## Users and Groups

| Type  | Name  | ID   |
| ----- | ----- | ---- |
| User  | `synapse` | 8080 |
| Group | `synapse` | 8080 |

### Networking

| Port | Protocol | Description |
| ---- | -------- | ----------- |
| `8008` | `tcp`    | Synapse Homeserver |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.


## Support & Maintenance

* For community help, tips, and community discussions, visit the Discussions board.
* For personalized support or a support agreement, see Nfrastack Support.
* To report bugs, submit a Bug Report. Usage questions will be closed as not-a-bug.
* Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
* Updates are best-effort, with priority given to active production use and support agreements.

## References

* <https://matrix.org/docs/projects/server/synapse>

## License

This project is licensed under the MIT License - see the LICENSE file for details.
