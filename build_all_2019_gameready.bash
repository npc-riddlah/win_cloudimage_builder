#!/bin/bash

./runbuild/build_2019DatacenterEn_Gameready.bash > log/build_2019DatacenterEn_Gameready.log 2>&1 &
./runbuild/build_2019DatacenterRu_Gameready.bash > log/build_2019DatacenterRu_Gameready.log 2>&1 &
./runbuild/build_2019StandardEn_Gameready.bash > log/build_2019StandardEn_Gameready.log 2>&1 &
./runbuild/build_2019StandardRu_Gameready.bash > log/build_2019StandardRu_Gameready.log 2>&1 &

exit 0
