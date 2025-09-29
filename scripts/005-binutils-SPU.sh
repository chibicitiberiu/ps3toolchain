#!/bin/sh -e
# binutils-SPU.sh by Naomi Peori (naomi@peori.ca)

## Check if binutils-SPU is already installed
if [ -f "$PS3DEV/spu/bin/spu-as" ] && [ -f "$PS3DEV/spu/bin/spu-ld" ]; then
    echo "binutils-SPU already installed, skipping..."
    exit 0
fi

BINUTILS="binutils-2.22"

if [ ! -d ${BINUTILS} ]; then

  ## Download the source code.
  BINUTILS_MIRROR="${BINUTILS_MIRROR:-https://ftp.gnu.org/gnu/binutils}"
  CONFIG_MIRROR="${CONFIG_MIRROR:-https://git.savannah.gnu.org/cgit/config.git/plain}"
  if [ ! -f ${BINUTILS}.tar.bz2 ]; then wget --continue ${BINUTILS_MIRROR}/${BINUTILS}.tar.bz2; fi

  ## Download an up-to-date config.guess and config.sub
  if [ ! -f config.guess ]; then wget --continue ${CONFIG_MIRROR}/config.guess; fi
  if [ ! -f config.sub ]; then wget --continue ${CONFIG_MIRROR}/config.sub; fi

  ## Unpack the source code.
  tar xfvj ${BINUTILS}.tar.bz2

  ## Patch the source code.
  cat ../patches/${BINUTILS}-PS3-SPU.patch | patch -p1 -d ${BINUTILS}

  ## Replace config.guess and config.sub
  cp config.guess config.sub ${BINUTILS}

fi

if [ ! -d ${BINUTILS}/build-spu ]; then

  ## Create the build directory.
  mkdir ${BINUTILS}/build-spu

fi

## Enter the build directory.
cd ${BINUTILS}/build-spu

## Configure the build.
../configure --prefix="$PS3DEV/spu" --target="spu" \
    --disable-nls \
    --disable-shared \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-werror \
    --with-gcc \
    --with-gnu-as \
    --with-gnu-ld \
		--enable-lto

## Compile and install.
PROCS="$(nproc --all 2>&1)" || ret=$?
if [ ! -z $ret ]; then PROCS=4; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} libdir=host-libs/lib install
