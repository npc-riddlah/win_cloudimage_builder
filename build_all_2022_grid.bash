#!/bin/bash

./runbuild/build_2022DatacenterRu_GRID.bash > log/build_2022DatacenterRu_GRID.log 2>&1 &
./runbuild/build_2022StandardRu_GRID.bash > log/build_2022StandardRu_GRID.log 2>&1 &


exit 0
