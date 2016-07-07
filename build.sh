#!/bin/bash

TARBALL_URL="https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz"
TARBALL_SHA256="b87c738cb2032bf4920fef8e3864dc5cf8eae9d89d8d523ce0236945c5797dcd"
TARBALL=$(basename $TARBALL_URL)

DIRNAME="${TARBALL%.*.*}"
DEST=${DIRNAME}-files

VERSION=2.3.1
PACKAGE_NAME=ruby
PACKAGE_VERSION=1:${VERSION}.0
USER=`whoami`

LICENSE='GPLv2'
MAINTAINER='<brad.heller@gmail.com>'
DESCRIPTION='A dynamic, open source programming language with a focus on simplicity and productivity.'
VENDOR='The Ruby community'

#
# Boilerplate for downloading/installing all the relevant dependencies.
#
sudo apt-get -y upgrade
sudo apt-get -y update

sudo apt-get -y install \
  build-essential \
  curl \
  bison \
  openssl \
  libreadline6 \
  libreadline6-dev \
  zlib1g \
  zlib1g-dev \
  libssl-dev \
  libyaml-dev \
  libxml2-dev \
  libxslt-dev \
  autoconf \
  libc6-dev \
  ncurses-dev \
  libcurl4-openssl-dev \
  apache2-prefork-dev \
  libapr1-dev \
  libaprutil1-dev \
  libffi-dev

#
# If the tarball isn't there, let's download it.
if [[ ! -f ${TARBALL} ]];
then
  curl ${TARBALL_URL} > $(basename ${TARBALL})
fi

#
# Start with a fresh extract every time, too.
if [[ -f ${DIRNAME} ]];
then
  rm -rf ${DIRNAME}
fi

tar -xvzf ${TARBALL}

# Build all the things.
pushd ${DIRNAME}
./configure
make
sudo make install
popd

#
# Gather all the files that were installed by Ruby.
rm -rf ${DEST}
mkdir ${DEST}

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ -f $line ]];
  then
    mkdir -p ${DEST}$(dirname ${line})
    sudo cp $line ${DEST}${line}
  fi
done < "${DIRNAME}/.installed.list"

#
# If FPM isn't installed then let's do it.
FPM=`which fpm`

if [[ ! -e ${FPM} ]];
then
  sudo gem install fpm
fi

#
# We change ownership of all of these so that we can read them explicitly.
sudo chown -R ${USER}:${USER} ./${DEST}

#
# We rewrite this so that it matches the input format for FPM.
find ./${DEST} -type f | sed "s/${DEST}\\(.*\\)$/${DEST}\\1=\\1/" > inputs.txt

#
# Clean up any deb old deb packages.
rm ./*.deb

#
# Now let's create the actual package.
fpm -s dir -t deb --name ${PACKAGE_NAME} \
  --package ${PACKAGE_NAME}-${VERSION}-amd64.deb \
  --architecture amd64 \
  --version "${PACKAGE_VERSION}" \
  --license "${LICENSE}" \
  --description "${DESCRIPTION}" \
  --vendor "${VENDOR}" \
  --maintainer "${MAINTAINER}" \
  --inputs ./inputs.txt
