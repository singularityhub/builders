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

# Web Log

WEBROOT=/var/www/html
WEBLOG="${WEBROOT}/sregistry.log"
sudo touch $LOGFILE && sudo chmod 757 $WEBLOG
echo "Installing Singularity Dependencies" | tee -a $WEBLOG

sudo apt-get -y install git \
                   build-essential \
                   libtool \
                   libarchive-dev \
                   squashfs-tools \
                   autotools-dev \
                   automake \
                   autoconf \
                   debootstrap \
                   yum \
                   nginx \
                   uuid-dev \
                   libssl-dev


echo "Preparing logging..." | tee -a $WEBLOG
sudo service nginx start
IPADDRESS=`echo $(hostname -I) | xargs`
echo "Logs available at http://$IPADDRESS/" | tee -a $WEBLOG


# Robot Web Reporter

if [ -f "index.html" ]; then
    sudo cp index.html $WEBROOT
else
    echo "Cannot find web index.html file in $PWD";
fi


# Metadata

METADATA="http://metadata/computeMetadata/v1/instance/attributes"
HEAD="Metadata-Flavor: Google"

SINGULARITY_REPO=$(curl ${METADATA}/SINGULARITY_REPO -H "${HEAD}")
SINGULARITY_BRANCH=$(curl ${METADATA}/SINGULARITY_BRANCH -H "${HEAD}")
SINGULARITY_RECIPE=$(curl ${METADATA}/SINGULARITY_RECIPE -H "${HEAD}")
SINGULARITY_COMMIT=$(curl ${METADATA}/SINGULARITY_COMMIT -H "${HEAD}")
SREGISTRY_USER_REPO=$(curl ${METADATA}/SREGISTRY_USER_REPO -H "${HEAD}")
SREGISTRY_USER_BRANCH=$(curl ${METADATA}/SREGISTRY_USER_BRANCH -H "${HEAD}")
SREGISTRY_USER_COMMIT=$(curl ${METADATA}/SREGISTRY_USER_COMMIT -H "${HEAD}")
SREGISTRY_USER_TAG=$(curl ${METADATA}/SREGISTRY_USER_TAG -H "${HEAD}")
SREGISTRY_CONTAINER_NAME=$(curl ${METADATA}/SREGISTRY_CONTAINER_NAME -H "${HEAD}")

SREGISTRY_BUILDER_STORAGE_BUCKET=$(curl ${METADATA}/SREGISTRY_BUILDER_STORAGE_BUCKET -H "${HEAD}")

echo "
# SINGULARITY

SINGULARITY_REPO: ${SINGULARITY_REPO}
    The Singularity repository being cloned by the builder. 
SINGULARITY_BRANCH: ${SINGULARITY_BRANCH}
    The branch of the repository being used.
SINGULARITY_COMMIT: ${SINGULARITY_COMMIT}
    If defined, a particular commit to checkout.

# SETTINGS

SREGISTRY_USER_REPO: ${SREGISTRY_USER_REPO}
    Your repository we are building from!
SINGULARITY_RECIPE: ${SINGULARITY_RECIPE}
    The recipe file in queue for build!
SREGISTRY_USER_BRANCH: ${SREGISTRY_USER_BRANCH}
    The branch we are cloning to do your build.
SREGISTRY_USER_BRANCH: ${SREGISTRY_USER_TAG}
     The tag for the image.
" | tee -a $WEBLOG


# Singularity

BUILDDIR=$PWD
echo "# Installing Singularity" | tee -a $WEBLOG
echo
echo "git clone -b $SINGULARITY_BRANCH $SINGULARITY_REPO" | tee -a $WEBLOG
cd /tmp && git clone -b $SINGULARITY_BRANCH $SINGULARITY_REPO singularity && cd singularity

# Commit

if [ -x "${SINGULARITY_COMMIT}" ]; then
    git checkout $SINGULARITY_COMMIT .
else
    SINGULARITY_COMMIT=$(git log -n 1 --pretty=format:"%H")
fi

echo "Using commit ${SINGULARITY_COMMIT}" | tee -a $WEBLOG

# Install

./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install && sudo make secbuildimg
RETVAL=$?
echo "Install return value $RETVAL" | tee -a $WEBLOG
echo $(which singularity) | tee -a $WEBLOG

cd $BUILDDIR

# User Repo Clone

echo
echo "Build"
echo
echo "Cloning User Repository $SREGISTRY_USER_REPO" | tee -a $WEBLOG
echo "git clone -b $SREGISTRY_USER_BRANCH $SREGISTRY_USER_REPO" | tee -a $WEBLOG
git clone -b $SREGISTRY_USER_BRANCH $SREGISTRY_USER_REPO build-repo && cd build-repo

# Commit

if [ -x "${SREGISTRY_USER_COMMIT}" ]; then
    git checkout $SREGISTRY_USER_COMMIT .
else
    SREGISTRY_USER_COMMIT=$(git log -n 1 --pretty=format:"%H")
fi

echo "Using commit ${SREGISTRY_USER_COMMIT}" | tee -a $WEBLOG

# Build

CONTAINER=$SREGISTRY_USER_COMMIT.simg

if [ -f "$SINGULARITY_RECIPE" ]; then

    # Record time and perform build
    echo "Found recipe: ${SINGULARITY_RECIPE}" | tee -a $WEBLOG
    echo "Start Time: $(date)." | tee -a $WEBLOG
    sudo singularity build $CONTAINER "${SINGULARITY_RECIPE}" | tee -a $WEBLOG

    # Assess return value
    ret=$?
    echo "Return value of ${ret}." | tee -a $WEBLOG
    if [ $ret -eq 137 ]; then
        echo "Killed: $(date)." | tee -a $WEBLOG
    else
        echo "End Time: $(date)." | tee -a $WEBLOG
    fi

else

    # The recipe was not found!

    echo "${SINGULARITY_RECIPE} is not found."  | tee -a $WEBLOG
    ls | tee -a $WEBLOG
fi


# Storage

if [ -f ${CONTAINER} ]; then

    echo 
    echo "# Storage"
    echo

    STORAGE_FOLDER="gs://$SREGISTRY_BUILDER_STORAGE_BUCKET/github.com/$SREGISTRY_CONTAINER_NAME/$SREGISTRY_USER_BRANCH/$SREGISTRY_USER_COMMIT"
    CONTAINER_HASH=($(sha256sum "${CONTAINER}"))
    CONTAINER_UPLOAD="${STORAGE_FOLDER}/${CONTAINER_HASH}:${SREGISTRY_USER_TAG}.simg"

    echo "Upload with format: 
[storage-bucket]     : ${SREGISTRY_BUILDER_STORAGE_BUCKET} 
[github-namespace]   : github.com/[container]/[branch]/[commit]
  [container]        : ${SREGISTRY_CONTAINER_NAME}
  [commit]           : ${SREGISTRY_USER_COMMIT}
  [branch]           : ${SREGISTRY_USER_BRANCH}
[sha256sum]          : ${CONTAINER_HASH}
[tag]                : ${SREGISTRY_USER_TAG}
gs://[storage-bucket]/github.com/[github-namespace]/[sha256sum]:[tag].simg

${CONTAINER_UPLOAD}
" | tee -a $WEBLOG

    echo "gsutil  cp -a public-read $CONTAINER $CONTAINER_UPLOAD"  | tee -a $WEBLOG
    gsutil -h "x-goog-meta-type:container" \
           -h "x-goog-meta-client:sregistry" \
           -h "x-goog-meta-tag:${SREGISTRY_USER_TAG}" \
           -h "x-goog-meta-commit:${SREGISTRY_USER_COMMIT}" \
           -h "x-goog-meta-hash:${CONTAINER_HASH}" \
           -h "x-goog-meta-uri:${SREGISTRY_CONTAINER_NAME}:${SREGISTRY_USER_TAG}@${SREGISTRY_USER_COMMIT}" \
           cp -a public-read $CONTAINER $CONTAINER_UPLOAD | tee -a $WEBLOG

    # Finalize Log

    LOG_UPLOAD="${STORAGE_FOLDER}/${CONTAINER_HASH}:${SREGISTRY_USER_TAG}.log"
    gsutil cp -a public-read "${WEBLOG}" "${LOG_UPLOAD}"

else
    echo "Container was not built, skipping upload to storage."  | tee -a $WEBLOG    
fi

# Return to build bundle folder, in case other stuffs to do.

cd $BUILDDIR
