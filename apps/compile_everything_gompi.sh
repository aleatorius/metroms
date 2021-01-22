#!/bin/bash

source myenv_gfram.bash
source modules_gompi.sh

./build_mct.sh
./build_cice_gbetzy.sh SA4 12 8
./build_roms_gbetzy.sh SA4 -j 4 

