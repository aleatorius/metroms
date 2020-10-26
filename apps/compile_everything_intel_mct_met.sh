#!/bin/bash

source myenv.bash
source modules_vilje.sh

./build_mct.sh
./build_cice_vilje.sh SA4 12 8
./build_roms.sh SA4 -j 4 

