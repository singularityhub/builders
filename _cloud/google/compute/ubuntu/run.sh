#!/bin/bash

################################################################################
# Instance Preparation
# For Google cloud, Stackdriver/logging should have Write, 
#                   Google Storage should have Full
#                   All other APIs None,
#
#
# Copyright (C) 2018 The Board of Trustees of the Leland Stanford Junior
# University.
# Copyright (C) 2018 Vanessa Sochat.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public
# License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
################################################################################

echo "Installing Singularity Dependencies"

sudo apt-get -y install git \
                   build-essential \
                   libtool \
                   squashfs-tools \
                   autotools-dev \
                   automake \
                   autoconf \
                   debootstrap \
                   yum \
                   uuid-dev \
                   libssl-dev


# Metadata


METADATA="http://metadata/computeMetadata/v1/instance/attributes"
SINGULARITY_REPO=$(curl ${METADATA}/SINGULARITY_REPO -H "Metadata-Flavor: Google")
SINGULARITY_BRANCH=$(curl ${METADATA}/SINGULARITY_BRANCH -H "Metadata-Flavor: Google")
SINGULARITY_RUNSCRIPT=$(curl ${METADATA}/SINGULARITY_RUNSCRIPT -H "Metadata-Flavor: Google")
SINGULARITY_COMMIT=$(curl ${METADATA}/SINGULARITY_COMMIT -H "Metadata-Flavor: Google")
BUILDER_STORAGE_BUCKET=$(curl ${METADATA}/BUILDER_STORAGE_BUCKET -H "Metadata-Flavor: Google")
BUILDER_LOGFILE=$(curl ${METADATA}/BUILDER_LOGFILE -H "Metadata-Flavor: Google")
BUILDER_KILLHOURS=$(curl ${METADATA}/BUILDER_KILLHOURS -H "Metadata-Flavor: Google")
SINGULARITY_FOLDER=$(basename $REPO)


# Singularity

echo "Installing Singularity"
git clone -b $SINGULARITY_BRANCH $SINGULARITY_REPO && cd "${SINGULARITY_FOLDER}"


# Commit

if [ -x "${SINGULARITY_COMMIT}" ]; then
    git checkout $SINGULARITY_COMMIT .
else
    SINGULARITY_COMMIT=$(git log -n 1 --pretty=format:"%H")
fi

echo "Using commit ${SINGULARITY_COMMIT}"

# Install

./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install && sudo make secbuildimg


# Write parameters to log
#TODO

# Run build

#TODO: image should be named something specific... hash? version? 
# If we name hash, can rename file at end.

echo "Start Time: $(date)." > ${SREGISTRY_LOGFILE} 2>&1
timeout -s KILL ${BUILDER_KILLHOURS}h sudo singularity build container.simg "${SINGULARITY_RECIPE}" >> ${BUILDER_LOGFILE} 2>&1
ret=$?

echo "Return value of ${ret}." >> "${BUILDER_LOGFILE}" 2>&1

if [ $ret -eq 137 ]
then
    echo "Killed: $(date)." >> "${BUILDER_LOGFILE}" 2>&1
else
    echo "End Time: $(date)." >> "${BUILDER_LOGFILE}" 2>&1
fi

# Finalize Log

#TODO

#image hash, size, etc.

# https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances?hl=en_US
# Instance will kill after finish. Permissions are needed for doing so on the server
instanceName=$(hostname)

# Extract zone and name from environment
zoneMetadata=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor:Google")
IFS=$'/'
zoneMetadataSplit=($zoneMetadata)
myZone="${zoneMetadataSplit[3]}"
gcloud compute instances delete $instanceName --zone $myZone --quiet

# Builder then kills self :)
