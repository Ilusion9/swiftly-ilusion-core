# Description
This project is designed to be a base addons for CS2 servers.

## Admin
Description: A basic admin plugin which uses permissions instead of flags. Edit configs/plugins/admin.json to give accesses.

Commands:
```
sw_reloadadmins - Reloads the admin cache - Permission "reloadadmins"
sw_who - Shows the online admins - Permission "who"
```

Requirements:
```
help
helpers
```

## AFK
Description: Gives punishments to AFK players. Edit configs/plugins/afk.json to change the punishments.

Requirements:
```
helpers
```

## Ban
Description: Bans players. A MySQL database is required. Edit configs/databases.cfg to add a database connection. 

```
    "ban": {
        "hostname": "",
        "username": "",
        "password": "",
        "database": "",
        "port": 3306,
        "kind": "mysql"
    }
```

Configuration: A time limit is specified in configs/plugins/ban.json. Use 0 or "permban" permission to ignore that.

Commands:
```
sw_ban <@steam|#userid|name> <time> <reason> - Bans a player - Permission "ban" (and "permban" for no time limit)
sw_ban_database_create - Creates the player ban database - Permission "rcon"
sw_ban_database_delete - Deletes the player ban database - Permission "rcon"
sw_banhistory [@steam|#userid|name] - Shows a player's ban history - Permission "banhistory" if target is specified
sw_unban <@steam> - Unbans a player - Permission "unban"
```

Requirements:
```
admin
helpers
```

## Gag
Description: Gags players. A MySQL database is required. Edit configs/databases.cfg to add a database connection. 

```
    "gag": {
        "hostname": "",
        "username": "",
        "password": "",
        "database": "",
        "port": 3306,
        "kind": "mysql"
    }
```

Configuration: A time limit is specified in configs/plugins/gag.json. Use 0 or "permgag" permission to ignore that.

Commands:
```
sw_gag <@steam|#userid|name> <time> <reason> - Gags a player - Permission "gag" (and "permgag" for no time limit)
sw_gag_database_create - Creates the player gag database - Permission "rcon"
sw_gag_database_delete - Deletes the player gag database - Permission "rcon"
sw_gaghistory [@steam|#userid|name] - Shows a player's gag history - Permission "gaghistory" if target is specified
sw_ungag <@steam> - Ungaggs a player - Permission "ungag"
```

Requirements:
```
admin
helpers
```

## Mute
Description: Mutes players. A MySQL database is required. Edit configs/databases.cfg to add a database connection. 

```
    "mute": {
        "hostname": "",
        "username": "",
        "password": "",
        "database": "",
        "port": 3306,
        "kind": "mysql"
    }
```

Configuration: A time limit is specified in configs/plugins/mute.json. Use 0 or "permmute" permission to ignore that.

Commands:
```
sw_mute <@steam|#userid|name> <time> <reason> - Mutes a player - Permission "mute" (and "permmute" for no time limit)
sw_mute_database_create - Creates the player mute database - Permission "rcon"
sw_mute_database_delete - Deletes the player mute database - Permission "rcon"
sw_mutehistory [@steam|#userid|name] - Shows a player's mute history - Permission "mutehistory" if target is specified
sw_unmute <@steam> - Unmutes a player - Permission "unmute"
```

Requirements:
```
admin
helpers
```
