# firebird2.1-docker

Firebird 2.1 instance running on an Ubuntu Precise image.

## Volumes

- /var/lib/firebird/2.1/data 

This is where the Firebird data files will live.

- /var/lib/firebird/2.1/backup 

This is where the FBK backup files will be created on backup.sh launch.

- /opt/admin/scripts/backres/log

Where the backup.sh and restore.sh log files will be placed.

- /opt/admin/scripts/backres/tmp

Where the tempfiles the backup.sh and restore.sh will work with will be placed.

## Use examples

### Build

```sh
$ docker build -t dockerbird2.1 .
```

### Run

```sh
mkdir /tmp/{log,tmp,data,backup}

docker run -d \
    --hostname dockerbird \
    --name dockerbird \
    -p 3050:3050 \
    -v /tmp/dockebird/data:/var/lib/firebird/2.1/data \
    -v /tmp/dockebird/backup:/var/lib/firebird/2.1/backup \
    -v /tmp/dockebird/log:/opt/admin/scripts/backres/log \
    -v /tmp/dockebird/tmp:/opt/admin/scripts/backres/tmp \
    -v /etc/localtime:/etc/localtime:ro \
    --restart always \
    dockerbird2.1
```

### Backup

```sh
docker exec -it -u firebird dockerbird2.1 /opt/admin/scripts/backres/backup.sh /var/lib/firebird/2.1/data/sample.fdb /var/lib/firebird/2.1/backup/sample.fbk
```

### Restore
```sh
docker exec -it -u firebird dockerbird2.1 /opt/admin/scripts/backres/restore.sh /var/lib/firebird/2.1/backup/sample.fbk /var/lib/firebird/2.1/data/sample.fdb
```
