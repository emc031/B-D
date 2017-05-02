#!/bin/bash

cfg_start=300
cfg_end=5560
dcfg=5

cfgs=$(seq $cfg_start $dcfg $cfg_end)
cfgs="2145 2180 2245"

for cfg in $cfgs; do 
    echo running $cfg
    sbatch submit-master.sh $cfg
done