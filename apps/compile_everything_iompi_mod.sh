#!/bin/bash

source myenv_fram.bash
source modules_iompi.sh

./build_mct_mod.sh
./build_cice_betzy.sh SA4 12 8
./build_roms_betzy.sh SA4 -j 4 

