# Odoo 19.0 with TimescaleDB for Real-time Analytics

## Quick Installation

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) yourself, then run the following to set up Odoo instance with TimescaleDB @ `localhost:10019` (default master password: `minhng.info`):

``` bash
curl -s https://raw.githubusercontent.com/minhng92/odoo-timescaledb/master/run.sh | bash -s odoo-one 10019 20019
```

Some arguments:
* First argument (**odoo-one**): Odoo deploy folder
* Second argument (**10019**): Odoo port
* Third argument (**20019**): live chat port

If `curl` is not found, install it:

``` bash
$ sudo apt-get install curl
# or
$ sudo yum install curl
```

## Architecture Overview

This setup integrates **Odoo 19** with **TimescaleDB** (PostgreSQL 17.6 with TimescaleDB 2.22.1) for enhanced real-time analytics capabilities:

- **Odoo 19**: Latest Odoo version with all business applications
- **TimescaleDB**: Time-series database optimized for real-time analytics
- **Real-time Analytics**: Enhanced reporting and time-series data analysis

## Usage

Start the container:
``` sh
docker-compose up
```
Then open `localhost:10019` to access Odoo 19.

- **If you get any permission issues**, change the folder permission to make sure that the container is able to access the directory:

``` sh
$ sudo chmod -R 777 addons
$ sudo chmod -R 777 etc
$ sudo chmod -R 777 _data
```

- If you want to start the server with a different port, change **10019** to another value in **docker-compose.yml** inside the parent dir:

```
ports:
 - "10019:8069"
```

- To run Odoo container in detached mode (be able to close terminal without stopping Odoo):

```
docker-compose up -d
```

- To Use a restart policy, i.e. configure the restart policy for a container, change the value related to **restart** key in **docker-compose.yml** file to one of the following:
   - `no` =	Do not automatically restart the container. (the default)
   - `on-failure[:max-retries]` =	Restart the container if it exits due to an error, which manifests as a non-zero exit code. Optionally, limit the number of times the Docker daemon attempts to restart the container using the :max-retries option.
  - `always` =	Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted. (See the second bullet listed in restart policy details)
  - `unless-stopped`	= Similar to always, except that when the container is stopped (manually or otherwise), it is not restarted even after Docker daemon restarts.
```
 restart: always             # run as a service
```

- To increase maximum number of files watching from 8192 (default) to **524288**. In order to avoid error when we run multiple Odoo instances. This is an *optional step*. These commands are for Ubuntu user:

```
$ if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
$ sudo sysctl -p    # apply new config immediately
``` 

## TimescaleDB Integration

This setup uses **TimescaleDB** instead of standard PostgreSQL, providing:

- **Time-series optimization**: Better performance for time-based data
- **Real-time analytics**: Enhanced reporting capabilities
- **Hybrid workloads**: Support for both transactional and analytical queries
- **Automatic partitioning**: Efficient data management for large datasets

### Database Configuration
- **Database**: TimescaleDB (PostgreSQL 17.6 + TimescaleDB 2.22.1)
- **Username**: odoo
- **Password**: odoo19@2025
- **Host**: timescaledb
- **Data Volume**: `./_data/postgresql:/home/postgres/pgdata/data`

## Custom addons

The **addons/** folder contains custom addons. Just put your custom addons if you have any.

## Odoo configuration & log

* To change Odoo configuration, edit file: **etc/odoo.conf**.
* Log file: **etc/odoo-server.log**
* Default database password (**admin_passwd**) is `minhng.info`, please change it @ [etc/odoo.conf#L75](/etc/odoo.conf#L75)

## Odoo container management

**Run Odoo**:

``` bash
docker-compose up -d
```

**Restart Odoo**:

``` bash
docker-compose restart
```

**Stop Odoo**:

``` bash
docker-compose down
```

## Live chat

In [docker-compose.yml#L20](docker-compose.yml#L20), we exposed port **20019** for live-chat on host.

Configuring **nginx** to activate live chat feature (in production):

``` conf
#...
server {
    #...
    location /longpolling/ {
        proxy_pass http://0.0.0.0:20019/longpolling/;
    }
    #...
}
#...
```

## Screenshots

<p align="center">
<img src="screenshots/odoo-19-welcome-screenshot.jpg" width="50%">
</p>

<p>
<img src="screenshots/odoo-19-apps-screenshot.jpg" width="100%">
</p>

<p>
<img src="screenshots/odoo-19-dashboard.jpg" width="100%">
</p>

<p>
<img src="screenshots/odoo-19-sales-screen.jpg" width="100%">
</p>

<p>
<img src="screenshots/odoo-19-product-form.jpg" width="100%">
</p>

## ☕ Buy Me a Coffee

If you find this project helpful, consider buying me a coffee to support my work!

<a href="https://buymeacoffee.com/minhng.info" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
