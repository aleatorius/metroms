#!/bin/bash

# if [ $# -le 1 ]
# then
#   echo "Usage: $0 [vilje|metlocal]"
#   echo "Choose architecture..."
#   exit
# fi

echo $METROMS_BASEDIR
echo $METROMS_TMPDIR
echo $METROMS_MYHOST
#export METROMS_MYHOST=metlocal
export METROMS_MYHOST=gfram
#export METROMS_MYHOST=$1

#export METROMS_MYARCH=Linux

if [ "$METROMS_MYHOST" == "metlocal" ]; then
    export METROMS_BASEDIR=/disk1/$USER
    export METROMS_TMPDIR=/disk1/$USER
elif [ "$METROMS_MYHOST" == "gfram" ]; then
    export METROMS_BASEDIR=$HOME
    export METROMS_TMPDIR=/cluster/work/users/$USER
    echo $METROMS_BASEDIR
    echo $METROMS_TMPDIR
    echo $METROMS_MYHOST

else
    echo "Undefined METROMS_MYHOST ", $METROMS_MYHOST
fi


export PYTHONPATH=$PYTHONPATH:$METROMS_BASEDIR/models/metroms/apps/common/python/
