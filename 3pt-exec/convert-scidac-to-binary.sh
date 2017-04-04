#! /bin/bash
#####################################################################################
# Script to convert Scidac format propagator to plain binary and get the source
# used to generate it.
# Rachel Dowdall 19th April 2012
#
# Takes one input variable, the name of the propagator.
# The output is ${propname}.binary and ${propname}.source.binary
#
# Note that the ordering of the data is different to Eduardo Follana's propagators.
# Data is stored as 3 colour vectors, i.e. outermost loop is colour not time.
# t=0 in the file is always t=0 in the gauge cfg unlike Eduardo's which start at
# the quark source. So if the quark source was at t=5, the prop starts at the 5th
# entry in the file.
#####################################################################################


#############################################################
# Functions:
#############################################################
convert() 
{
echo "Converting Scidac propagator file"
/lustre2/dc-mcle2/bin/lime_unpack ${SCIDAC_DIR}/${SCIDAC_FILE}

FOLDER=${SCIDAC_DIR}/${SCIDAC_FILE}.contents
echo
echo "Data in folder: "
echo ${FOLDER}

#msg03.rec03.scidac-binary-data
echo "Reformatting propagator"
cat  ${FOLDER}/msg03.rec03.scidac-binary-data ${FOLDER}/msg05.rec03.scidac-binary-data ${FOLDER}/msg07.rec03.scidac-binary-data   > ${PROP_FILENAME}
#cat  ${FOLDER}/msg03.rec03.scidac-binary-data ${FOLDER}/msg04.rec03.scidac-binary-data ${FOLDER}/msg05.rec03.scidac-binary-data  > ${PROP_FILENAME}
echo "Propagator stored as: ${PROP_FILENAME}"

# check the file size is correct:
ACTUAL_SIZE=$(stat -c%s "${PROP_FILENAME}")
let EXPECTED_SIZE=$Lx*$Lx*$Lx*$Lt*8*3*3*2
echo "Expected filesize: ${EXPECTED_SIZE}"
echo "Actual filesize: ${ACTUAL_SIZE}"
echo
if [ ${ACTUAL_SIZE} != ${EXPECTED_SIZE}   ]
 then echo "************************************"
      echo "Error: Propagator filesize incorrect"
      exit 0
fi


#echo "Reformatting quark source"
#cat   ${FOLDER}/msg02.rec03.scidac-binary-data ${FOLDER}/msg04.rec03.scidac-binary-data ${FOLDER}/msg06.rec03.scidac-binary-data > ${SOURCE_FILENAME}
#echo "Quark source stored as: ${SOURCE_FILENAME}"

# check the file size is correct:
#ACTUAL_SIZE=$(stat -c%s "${SOURCE_FILENAME}")
#let EXPECTED_SIZE=$Lx*$Lx*$Lx*8*3*3*2
#echo "Expected filesize: ${EXPECTED_SIZE}"
#echo "Actual filesize: ${ACTUAL_SIZE}"

#if [ ${ACTUAL_SIZE} != ${EXPECTED_SIZE}   ]
# then echo "************************************"
#      echo "Error: Quark source filesize incorrect"
#      exit 0
#fi

# remove the folder now we are finished with it
rm ${SCIDAC_DIR}/${SCIDAC_FILE}.contents/msg*
rmdir ${SCIDAC_DIR}/${SCIDAC_FILE}.contents
if [ -d ${SCIDAC_DIR}/${SCIDAC_FILE}.contents ];
then
    echo "Unable to remove extracted lime data in ${SCIDAC_FILE}.contents."
    exit 1
fi



}

#############################################################
# Get propagator filename from command line
prop_name=$1

if [ $# -lt 1 ]
then
    echo "Usage $0 <Scidac propagator filename>"
    exit 1
fi





# Specify file and lattice size
# We assume it is in double precision

#SCIDAC_FILE=propoutl1648.200-loc-t2.scidac
#SCIDAC_FILE=propoutl1648.200wallt1
#PROP_FILENAME=propoutl1648.200-loc-t2.binary
#SOURCE_FILENAME=sourcel1648.200-loc-t2.binary
#SCIDAC_FILE=$1
#PROP_FILENAME=${SCIDAC_FILE}.binary
#SOURCE_FILENAME=${SCIDAC_FILE}.source.binary

SCIDAC_DIR=$1
SCIDAC_FILE=$2
OUTPUT_DIR=/lustre2/dc-mcle2/BtoD/3pt-exec/temp/
PROP_FILENAME=${OUTPUT_DIR}${SCIDAC_FILE}.binary
SOURCE_FILENAME=${OUTPUT_DIR}${SCIDAC_FILE}.source.binary

# Lattice size - for checking file sizes later
Lx=24
Lt=64


# Check the file exists and exit if not
if [ ! -f ${SCIDAC_DIR}/${SCIDAC_FILE} ];
then
    echo "Propagator file ${SCIDAC_FILE} not found!"
    exit 1
fi



# call the function
convert