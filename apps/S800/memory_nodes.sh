#!/bin/bash
out_memory=$1
if [ -z "$1" ]
  then
    echo "No argument supplied"
    out_memory="outfile"
fi
for HOST in $(cat slurm.hosts ) ; do echo $HOST >> $out_memory ; ssh $HOST "free" >> $out_memory ; done 
