#!/bin/bash

#e mclean dec 2016

#takes in configuration number from stdin
#writes an input file for the milc application

########### parameters #################

if [ $# -lt 1 ]; then
    echo "requires argument: cfg number"
    exit 1
else
    cfg=$1
fi

nx=32
ny=32
nz=32
nt=96

milcroot=/lustre2/dc-mcle2/BtoD/milc-exec/

#where stuff comes from
cfg_dir=/lustre3/cd449/from_rd419/configs/l3296f211b630m0074m037m440-coul-v5/
inlat=l3296f211b630m0074m037m440-coul.${cfg} #just the name of the cfg file
infile_dir=$milcroot/infiles/
wf_dir=$milcroot/wavefunctions/

#here's one i made earlier- reading in light props to combine with c to make D
lprop_dir=/lustre2/dc-sant2/fine_lattice/etas_fine_propagators/
lprop_file_split1=l3296f211b630m0074m037m440-coul.
lprop_file_split2=_wallprop_m0.0376_th0.0_t

#physics
fpi_mass=( 0.450 0.0376 )
twist=2.637 #(3/4 of pmax = 3.516)
u0=1.0 #u0 has no effect in HISQ due to reunitirization
naik_epsilon=( -0.1256 0 )
sources=16 #keep on 4 during testing, change to 16 when ready
lspacing=0.088 #for use in wavefunction smearing

#smearing info
nsmear=2
smears=( "identity" "wavefunction" )
#wf_files=( "" "${wf_dir}/exp3.425_3296.wf" )
wf_file="${milcroot}/wavefunctions//exp3.425_3296.wf"
smearlabel=( "l" "e" )

#statistical precision
error_for_propagator=( 0 1e-8 )
rel_error_for_propagator=( 2e-14 0 )
max_cg_iterations=( 1000 1000 )

#where output goes
prop_dir=$milcroot/propagators/
corr_dir=$milcroot/correlators/set1_th2.637/ 
source_dir=$milcroot/sources/
#location & name of bumph (output from executable) and pbs (output from slurm)
#are set in submit-slurm-sandybridge.sh


########### automatic parameters #############

iseed=$cfg
infile=${infile_dir}/infile-${cfg}

#generating time source list
magic=19
source_increment=$(( $nt / $sources ))
cfg0=$(( $cfg / 5 ))
source_start=$(( ( $magic * $cfg0 )%( $nt / $sources ) ))
t0list=""
for i in $(seq $source_start $source_increment $(( $source_start + $source_increment * $sources - 1 )) ); do
    t0list="${t0list} $i"
done

########### writing input file #############

if [ -e $infile ]; then rm $infile; fi
touch $infile

wpnorm=1 #?
reload_gauge_cmd="reload_serial ${cfg_dir}${inlat}" #points milc to gauge configuration

cat << EOF >> $infile
prompt 0
nx ${nx}
ny ${ny}
nz ${nz}
nt ${nt}
iseed ${iseed}
job_id ${jobid}
EOF

# Iterate over source time slices
for t0 in $t0list; do
corrfile=${corr_dir}/corrfile.${inlat}_t${t0}


cat << EOF >> $infile

######################################################################
# source time ${t0}
######################################################################

# Gauge field description

${reload_gauge_cmd}
u0 ${u0}
no_gauge_fix
forget
staple_weight 0
ape_iter 0
coordinate_origin 0 0 0 0

# Chiral condensate and related measurements

number_of_pbp_masses 0

# Description of base sources

number_of_base_sources 2

# source 0
random_color_wall #source type
subset full
t0 ${t0}
ncolor 3
momentum 0 0 0
source_label c
#forget_source #output
save_serial_scidac_ks_source ${source_dir}/${inlat}_t${t0}_${smearlabel[0]} 

# source 1
vector_field
subset full
origin 0 0 0 ${t0}
load_source ${source_dir}/${inlat}_t${t0}_${smearlabel[0]} 
ncolor 3
momentum 0 0 0
source_label c
forget_source

# Description of completed sources

number_of_modified_sources $((nsmear-1))

EOF

for n in $(seq 1 $((nsmear-1)) ); do

cat << EOF >> $infile

# source $((n+1))
source 1
${smears[$n]}
load_source ${milcroot}/wavefunctions//exp3.425_3296.wf
a ${lspacing}
op_label ${smearlabel[$n]}
save_serial_scidac_ks_source ${source_dir}/${inlat}_t${t0}_${smearlabel[$n]} 

EOF
done

#### Definition of propagators for two sets ######

cat << EOF >> $infile

# Description of propagators

number_of_sets $((nsmear+1))

EOF

smearnumstring="0 "$(seq 2 $nsmear)
IFS=' ' read -r -a smearnums <<< "${smearnumstring}"

for n in $(seq 0 $((nsmear-1))); do
cat << EOF >> $infile

# set ${n} (${smears[$n]} charm)

max_cg_iterations ${max_cg_iterations[0]}
max_cg_restarts 3
check yes
momentum_twist ${twist} ${twist} ${twist}
time_bc periodic
precision 2

source ${smearnums[$n]}
number_of_propagators 1

# propagator ${n}

mass ${fpi_mass[0]}
naik_term_epsilon ${naik_epsilon[0]}
error_for_propagator ${error_for_propagator[0]}
rel_error_for_propagator ${rel_error_for_propagator[0]}
fresh_ksprop
#forget_ksprop
save_serial_scidac_ksprop ${prop_dir}/${inlat}_Rwallfull_m${fpi_mass[0]}_t${t0}_${smearlabel[$n]} 

EOF
done

cat << EOF >> $infile

# set ${nsmear} (${smears[0]} light)

max_cg_iterations ${max_cg_iterations[1]}
max_cg_restarts 3
check yes
momentum_twist 0 0 0
time_bc periodic
precision 2

source 1
number_of_propagators 1

# propagator ${nsmear}

mass ${fpi_mass[1]}
naik_term_epsilon ${naik_epsilon[1]}
error_for_propagator ${error_for_propagator[1]}
rel_error_for_propagator ${rel_error_for_propagator[1]}
reload_serial_ksprop ${lprop_dir}/${lprop_file_split1}${cfg}${lprop_file_split2}${t0} 
#fresh_ksprop #input
forget_ksprop #output


EOF
###### Definition of quarks #########


cat << EOF >> $infile

number_of_quarks $((nsmear*nsmear+1))

EOF

for m in $(seq 0 $((nsmear-1))); do
    for n in $(seq 0 $((nsmear-1))); do

cat << EOF >> $infile
# quark $((nsmear*m+n)) ( charm ${smearlabel[$n]} to ${smearlabel[$m]} )
propagator ${n} 
${smears[$m]} 
EOF

if [ ${smears[$m]} == "wavefunction" ]; then
cat << EOF >> $infile
load_source ${milcroot}/wavefunctions//exp3.425_3296.wf
a ${lspacing}
EOF
fi

cat << EOF >> $infile
op_label ${smearlabel[$m]}
forget_ksprop 

EOF
done
done

cat << EOF >> $infile

# quark $((nsmear*nsmear)) ( light ${smearlabel[0]} to ${smearlabel[0]} )
propagator ${nsmear} 
identity
op_label ${smearlabel[0]}
forget_ksprop

EOF
###### Specification of Mesons ########

cat << EOF >> $infile

# Description of mesons

number_of_mesons $((nsmear*nsmear+2))

EOF
for m in $(seq 0 $((nsmear-1))); do
    for n in $(seq 0 $((nsmear-1))); do

cat << EOF >> $infile

# meson $((nsmear*m+n)) (D ${smearlabel[$n]} to ${smearlabel[$m]})

pair $((nsmear*m+n)) $((nsmear*nsmear)) 
spectrum_request meson
save_corr_fnal ${corrfile}_Ds.${smearlabel[$n]}${smearlabel[$m]}
r_offset 0 0 0 ${t0}
number_of_correlators 1
correlator pi_gold p000  1 * ${wpnorm} pion5  0 0 0 E E E

EOF
done
done

cat << EOF >> $infile

# meson $((nsmear*nsmear)) (Kaon)

pair $((nsmear*nsmear)) $((nsmear*nsmear)) 
spectrum_request meson
save_corr_fnal ${corrfile}_kaon.${smearlabel[0]}${smearlabel[0]}
r_offset 0 0 0 ${t0}
number_of_correlators 1
correlator pi_gold p000  1 * ${wpnorm} pion5  0 0 0 E E E

# meson $((nsmear*nsmear+1)) (eta c)

pair 0 0 #input (quarks)
spectrum_request meson
save_corr_fnal ${corrfile}_etac.${smearlabel[0]}${smearlabel[0]} #output
r_offset 0 0 0 ${t0}
number_of_correlators 1
correlator pi_gold p000  1 * ${wpnorm} pion5  0 0 0 E E E

# Description of baryons
number_of_baryons 0

EOF

reload_gauge_cmd="continue"

done

