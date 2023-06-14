#!/bin/bash

./runbuild/build_2022DatacenterRu_Gameready.bash > log/build_2022DatacenterRu_Gameready.log 2>&1 &
./runbuild/build_2022StandardRu_Gameready.bash > log/build_2022StandardRu_Gameready.log 2>&1 &

exit 0
