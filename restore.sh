#!/bin/bash

die(){
	local _timestring="$(getTimeStr)"
	echo "$_timestring: $1" | tee -a $LOGDIR/${SCRIPT_NAME}.log
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

FBK_FILE=$1
FDB_FILE=$2
FDB_DIR=$(readlink -f $(dirname $FDB_FILE))

_GBAK_RESTORE_PARAMS="-v -USER SYSDBA -PAS masterkey -r"

if [ $# -ne 2 ]; then
	die "Falta ruta al fichero FDB y/o al FBK" 1
fi

if [ ! -s $FBK_FILE ]; then
	die "No se puede acceder al fichero $FBK_FILE" 2
fi

if [ ! -d $FDB_DIR ]; then
	die "No existe el directorio $FDB_DIR" 3
fi

if ! touch $FDB_DIR/.restore_test; then
	die "No se puede escribir en el directorio $FDB_DIR" 4
fi

for _workdir in $LOGDIR $TEMPDIR; do
	[ ! -d $_workdir ] && mkdir -p $_workdir
done

if [ -s $FDB_FILE ]; then
	rm -f $FDB_FILE || die "No se ha podido eliminar el fichero $FDB_FILE" 5
fi

gbak $_GBAK_RESTORE_PARAMS $FBK_FILE $FDB_FILE 2>&1 | tee $LOGDIR/${SCRIPT_NAME}.log
if [ ${PIPESTATUS[0]} -gt 0 ]; then
	die "No se ha podido realizar el restore del fichero $FBK_FILE sobre $FDB_FILE" 6
else
	chmod 660 $FDB_FILE || die "No se ha podido restaurar los permisos sobre $FDB_FILE" 7
fi

die "Restore realizado del fichero $FBK_FILE sobre $FDB_FILE correctamente" 0
