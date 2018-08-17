# Supported tags and respective `Dockerfile` links

* `latest` [(latest/Dockerfile)](https://github.com/Hackebein/docker-l4d2/blob/master/latest/Dockerfile)

# What is Left 4 Dead 2?

Left 4 Dead 2 is a cooperative first-person shooter video game. Set during the aftermath of an apocalyptic pandemic, fighting against hordes of zombies, known as the Infected, who develop severe psychosis and act extremely aggressive. The Survivors must fight their way through five campaigns, interspersed with safe houses that act as checkpoints, with the goal of escape at each campaign's finale.

# Update Hooks

* on base image update (supported by Docker Hub)
* on repository update (supported by Docker Hub)
* on steam repository content update (supported by [dexi.io](https://dexi.io))

# Quick Start

## Basic

```
docker run \
    --expose 27015 \
    hackebein/garrysmod
```

## Config

```
docker run \
    --expose 27015 \
    -v ./mycfg/server.cfg:/opt/garrysmod/garrysmod/volume/ \
    hackebein/garrysmod
```

Autoload `server.cfg` from volume.

## Additional Environment

PORT: Connection Port
(`Default: 27015`)

TICKRATE: Tickrate of server, **Attention:** Change not recommended
(`Default: 66`)

CLIENTPORT:
(`Default: 27005`)

MAP: Map on Server start
(`Default: c1m1_hotel`)

CONFIG: Server config, **Attention:** Change not recommended
(`Default: server.cfg`)

MAXPLAYERS: Max players
(`Default: 8`)

CUSTOMPARAMETERS: additional parameters
(`Default: `)
