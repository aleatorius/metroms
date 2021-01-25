#!/bin/bash

source myenv_fram.bash
source modules_iompi.sh

./build_mct.sh
./build_cice_betzy.sh SA4 17 13
./build_roms_betzy.sh SA4 -j 4 

