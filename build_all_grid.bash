#!/bin/bash

./build_2019DatacenterEn_GRID.bash > log/build_2019DatacenterEn_GRID.log 2>&1 &
./build_2019DatacenterRu_GRID.bash > log/build_2019DatacenterRu_GRID.log 2>&1 &
./build_2019StandardEn_GRID.bash > log/build_2019StandardEn_GRID.log 2>&1 &
./build_2019StandardRu_GRID.bash > log/build_2019StandardRu_GRID.log 2>&1 &
./build_2022DatacenterRu_GRID.bash > log/build_2022DatacenterRu_GRID.log 2>&1 &
./build_2022StandardRu_GRID.bash > log/build_2022StandardRu_GRID.log 2>&1 &

exit 0
