#!/bin/bash

# emclean march 2016

# takes stdin of the name of a directory containing results of a lattice simulation.
# for each configuration, it counts the number of "sucessful" files, i.e. the files
# which are of (roughly or greater than) the expected size 'exp_size'. 
# If a config does not have the expected number of successful files, 
# it's index is sent to stdout.

dir=$1
if [ -z "$dir" ]; then
    dir='.'
fi

echo $dir

cfg_pos=2 #file name is split into array acording to delimiters '._', cfg_pos is index of cfg number in this array. 
exp_size=2966 #target size of successfully outputed files
#pion correlators = 2900, nrqcd hl correlators = 12000, 3pt nrqcd correlators = 13000
files_per_cfg=96 #target number of files per config

#configs expected to be present
cfg_start=300
cfg_end=5560
dcfg=5

cfgs=$(seq $cfg_start $dcfg $cfg_end)

display=False

declare -A counter #stores the number of successful files which fall under each cfg

#initialize counter array
for cfg in $cfgs; do
    counter[$cfg]=0
done

#fill counter array. 

IFS=$'\n'
size_tol=$(( $exp_size-$exp_size/5 ))

for line in $( ls -l $dir ); do
   
    #get size
    size=$( echo $line | tr -s " " | cut -d' ' -f5 )

    #get cfg number
    file_name=$( echo $line | tr -s " " | cut -d' ' -f9 )
    IFS=$'._'
    str_arr=($file_name)
    cfg=$( echo ${str_arr[$cfg_pos]} )
    IFS=$'\n'

    #display cfgs and sizes to make sure the right strings are being read
    if [ $display == True ]; then
	echo "cfg="$cfg
	echo "size="$size
    fi

    #if file is the right size, add 1 to counter[cfg]
    if [ $size -ge $size_tol ]; then
        counter[$cfg]=$(( ${counter[$cfg]} + 1 ))
    fi

done

#echo unsuccessful cfgs according to counter array

unsuccessful=''
total=0

for cfg in $cfgs; do
    if [ ! ${counter[$cfg]} -ge $files_per_cfg ]; then
     	unsuccessful="${unsuccessful} $cfg"
	total=$(( $total + 1 ))
    fi
done

echo "unsuccessful cfgs = "
echo $unsuccessful
echo "total = ${total}"


exit 0