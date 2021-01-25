#!/bin/bash

source myenv_fram.bash
source modules_iimpi.sh

#./build_mct.sh
./build_cice_betzy.sh S800 17 13
./build_roms_betzy.sh S800 -j 4 

