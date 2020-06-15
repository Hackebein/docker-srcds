# What is Source Dedicated Server?

Valve call this Server [Source SDK Base 2013 Dedicated Server](https://steamdb.info/app/244310/). This Server builds the base for all source engine based games with dedicated server support.

# Quick Start

## Basic

```
docker run -it \
    --expose 27015 \
    hackebein/srcds
```

## Enable API

```
docker run -it \
    --expose 27015 \
    -e "AUTHKEY=..." \
    hackebein/srcds
```
Get your [AUTHKEY](http://steamcommunity.com/dev/apikey)

## Public
If you have activated the API, this step happens automatically.

```
docker run -it \
    --expose 27015 \
    -e "GLST=..." \
    hackebein/srcds
```

Get your [GLST](http://steamcommunity.com/dev/managegameservers) (`APPID: 244310`)

## Signals

Signals are catched and call a script `before` and `after` send the signal to the server executable.

```
docker run -it \
    --expose 27015 \
    -e "SIGNALS_ENABLE=true"
    -v ./SIGINT_before.sh:/opt/steam/SIGINT_before.sh \
    -v ./SIGTERM_after.sh:/opt/steam/SIGTERM_after.sh \
    hackebein/srcds
```

## Overlay folder

Copy files over before start server

```
docker run -it \
    --expose 27015 \
    -v ./overlay:/opt/overlay \
    hackebein/srcds
```

## SourceMod Plugins

```
docker run -it \
    --expose 27015 \
    -e "METAMOD=latest" \
    -e "SOURCEMOD=latest" \
    -e "AUTOUPDATE=true" \
    -e "SOURCEMOD_PLUGINS_INSTALL=https://example.com/myplugin1.zip,/opt/misc/myplugin2.smx" \
    -e "SOURCEMOD_PLUGINS_ENABLE=admin-flatfile,adminhelp,adminmenu,antiflood,basebans,basechat,basecomm,basecommands,basetriggers,basevotes,clientprefs,funcommands,funvotes,myplugin1,myplugin2,nextmap,playercommands,reservedslots,sounds" \
    -v ./myplugin2.smx:/opt/misc/myplugin2.smx \
    -v ./overlay:/opt/overlay \
    hackebein/srcds
```

## Additional Environment

LOGIN: Login information
(`Default: anonymous`)
Format: `<username> <password>`

PORT: Connection Port
(`Default: 27015`)

CLIENTPORT:
(`Default: 27005`)

TVPORT:
(`Default: 27020`)

SPORT:
(`Default: 26900`)

GLSTMEMO: automatic GLST registration memo
(`Default: <container-hostname>`)

SIGNALS_ENABLE: enable process signal handling
(`Default: false`)

APPS: AppIDs (required)
(`Default: 244310`)
Format: `<app_id> [-beta <betaname>] [-betapassword <password>][,...]`

GAME: game to start (required)
(`Default: `)

METAMOD: version of MetaMod to install
Examples: latest, 1.11, 1.10.7, 1.10.7.952
(`Default: `)

SOURCEMOD: version of SourceMod to install (requires MetaMod)
Examples: latest, 1.11, 1.10.0, 1.10.0.6482
(`Default: `)

SOURCEMOD_PLUGINS_INSTALL: plugins to install from local path or URL
(`Default: `)

SOURCEMOD_PLUGINS_ENABLE: plugins to enable
(`Default: admin-flatfile,adminhelp,adminmenu,antiflood,basebans,basechat,basecomm,basecommands,basetriggers,basevotes,clientprefs,funcommands,funvotes,nextmap,playercommands,reservedslots,sounds`)

STEAMWORKS: version of SteamWorks to install (requires SourceMod)
(`Default: latest`)

AUTOUPDATE: enables autorestart/autoupdate (requires SourceMod)
(`Default: false`)

WORKSHOPDL: downloads workshop collection for client before joining (garrysmod only)
(`Default: `)

CUSTOMPARAMETERS: additional parameters
(`Default: `)

## More Options

You can found more configuration options on the parent image page [hackebein/steamcmd](https://hub.docker.com/r/hackebein/steamcmd)
