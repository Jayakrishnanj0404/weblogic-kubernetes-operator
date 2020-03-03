#!/bin/bash
# Copyright 2019, Oracle Corporation and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#
# This script stages a wdt model to directory 'WORKDIR/models' for future inclusion
# in a model-in-image image:
#
#   - It builds the 'WORKDIR/sample_app' application 'ear' file, and puts the ear into
#     'WORKDIR/models/archive1.zip' along with the application's model mime mappings 
#     file 'WORKDIR/sample_app/wlsdeploy/config/amimemappings.properties'.
#
#   - It copies WDT model files that contain WebLogic configuration from
#     'WORKDIR' into 'WORKDIR/models'. It chooses the source model file
#     based on WDT_DOMAIN_TYPE.
#
#   NOTE: If you want to specify your own model files for an image, then you
#         don't need to run this script. Instead set environment variables
#         that indicate the location of your model files as per
#         the instructions in './build_image_model.sh'.
#
# This script also stages a wdt file to 'WORKDIR/wdtconfigmap' for future inclusion
# in a config map that's in turn referenced by a domain resource.
#
#   - It copies 'WORKDIR/model1.20.properties' to 'WORKDIR/wdtconfigmap'.
#
#   NOTE: If you want to specify your own model files for inclusion
#         in the wdt config map, then export WDTCONFIGMAPDIR prior
#         to running.
#
# This script expects the following env vars to already be set:
#    
#    WORKDIR - working directory for the sample with at least 10g of space
#
# Optionally set:
#
#    WDT_DOMAIN_TYPE - 'WLS' (default), 'JRF', or 'RestrictedJRF'.
#
#

set -eu

echo @@
echo @@ Info: Creating sample app model archive models/archive1.zip
echo @@

cd ${WORKDIR?}

mkdir -p ${WORKDIR}/models

cd sample_app/wlsdeploy/applications
rm -f sample_app.ear
jar cvfM sample_app.ear *

rm -f ${WORKDIR}/models/archive1.zip
cd ../..
zip ${WORKDIR}/models/archive1.zip wlsdeploy/applications/sample_app.ear wlsdeploy/config/amimemappings.properties

echo "@@"
echo "@@ Info: Setting up wdt models in directory ./models"
echo "@@"

cd ${WORKDIR?}

WDT_DOMAIN_TYPE=${WDT_DOMAIN_TYPE:-WLS}

if [ "${WDT_DOMAIN_TYPE}" == "WLS" -o "${WDT_DOMAIN_TYPE}" == "RestrictedJRF" ] ; then

  cp model1.yaml.wls models/model1.yaml

elif [ "${WDT_DOMAIN_TYPE}" == "JRF" ] ; then

  cp model1.yaml.jrf models/model1.yaml

else

  echo "@@ Error: Invalid domain type WDT_DOMAIN_TYPE '$WDT_DOMAIN_TYPE': expected 'WLS', 'JRF', or 'RestrictedJRF'." && exit 1

fi

cp model1.10.properties models/model1.10.properties

mkdir -p ${WORKDIR}/wdtconfigmap

cp model1.20.properties ${WORKDIR}/wdtconfigmap

