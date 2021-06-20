#!/bin/bash

die(){
	local _timestr="$(getTimeStr)"
	echo -e "$_timestr: $1" | tee -a $LOGDIR/${SCRIPT_NAME}.log
	exit $2
}

getTimeStr(){
	date --rfc-3339=seconds | awk '{print substr($0,1,19)}'
}


# Define script vars.
export LANG=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DAYNAME=$(date +"%A" | tr "[:upper:]" "[:lower:]")

SCRIPT_DIR=$(dirname $(readlink -f $0))
SCRIPT_NAME=$(basename $(echo ${0%.*}))

LOGDIR=$SCRIPT_DIR/log
TEMPDIR=$SCRIPT_DIR/tmp

FDB_FILE=$1
FBK_FILE=$2
FBK_DIR=$(readlink -f $(dirname $FBK_FILE))

_RSYNC_SRC=$FDB_FILE
_RSYNC_DST=$TEMPDIR/$(basename $FDB_FILE).$DAYNAME

_FDB_BACKUP="$SCRIPT_DIR/$(basename ${FDB_FILE%.fdb}.ultimo)"

_GBAK_BACKUP_PARAMS="-v -USER SYSDBA -PAS masterkey -b -t -ignore -garbage -limbo"

if [ $# -ne 2 ]; then
	die "Falta ruta al fichero FDB y/o al FBK" 1
fi

if [ ! -s $FDB_FILE ]; then
	die "No se puede acceder al fichero $FDB_FILE" 2
fi

if [ ! -d $FBK_DIR ]; then
	die "No existe el directorio $FBK_DIR" 3
fi

if ! touch $FBK_DIR/.backup_test; then
	die "No se puede escribir en el directorio $FBK_DIR" 4
fi

for _workdir in $LOGDIR $TEMPDIR; do
	[ ! -d $_workdir ] && mkdir -p $_workdir
done

if ! rsync -avP $_RSYNC_SRC $_RSYNC_DST; then
	die "No se ha podido realizar una copia del fichero $_RSYNC_SRC en $_RSYNC_DST" 5
fi

if [ -s $FBK_FILE ]; then
	rm -f $FBK_FILE || die "No se ha podido eliminar el fichero $FBK_FILE" 6
fi

gbak $_GBAK_BACKUP_PARAMS $FDB_FILE $FBK_FILE 2>&1 | tee $LOGDIR/${SCRIPT_NAME}.log
if [ ${PIPESTATUS[0]} -gt 0 ]; then
	die "No se ha podido realizar el backup del fichero $FDB_FILE sobre $FBK_FILE" 7
fi

if [ -L $_FDB_BACKUP ]; then
	rm -f $_FDB_BACKUP || die "No se ha podido eliminar el enlace ${_FDB_BACKUP}" 8
fi

if ! ln -s $_RSYNC_DST $_FDB_BACKUP; then
	die "No se ha podido crear el enlace ${_FDB_BACKUP}" 9
fi

die "Backup realizado del fichero $FDB_FILE sobre $FBK_FILE correctamente" 0
