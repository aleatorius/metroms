#!/bin/bash

source myenv_fram.bash
source modules_fram_intel_2019.sh

#./build_mct.sh
#./build_cice_betzy.sh SA4 12 8
./build_roms_betzy.sh SA4 -j 4 

