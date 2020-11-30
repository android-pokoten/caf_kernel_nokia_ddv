#!/bin/bash
BUILD_START=$(date +"%s")

# Colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Kernel details
KERNEL_NAME="Ayase"
VERSION="HILL"
DATE=$(date +"%d-%m-%Y-%I-%M")
DEVICE="DDV"
FINAL_ZIP=$KERNEL_NAME-$VERSION-$DATE.zip
defconfig=ayase_defconfig

# Dirs
BASE_DIR=`pwd`/../
KERNEL_DIR=$BASE_DIR/msm-4.4
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel3
KERNEL_IMG=$KERNEL_DIR/output/arch/arm64/boot/Image.gz-dtb
UPLOAD_DIR=$BASE_DIR/$DEVICE

# Export
export PATH="$BASE_DIR/toolchain/aarch64/aarch64-linux-android-4.9/bin:$PATH"
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

## Functions ##

# Make kernel
function make_kernel() {
  echo -e "$cyan***********************************************"
  echo -e "          Initializing defconfig          "
  echo -e "***********************************************$nocol"
  #make $defconfig CC=clang O=output/
  make $defconfig O=output/
  echo -e "$cyan***********************************************"
  echo -e "             Building kernel          "
  echo -e "***********************************************$nocol"
  #make -j$(nproc --all) CC=clang O=output/
  make -j$(nproc --all) O=output/
  if ! [ -a $KERNEL_IMG ];
  then
    echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
    exit 1
  fi
}

# Config kernel
function config_kernel() {
  #make menuconfig CC=clang O=output/
  make menuconfig O=output/
}

# Making zip
function make_zip() {
cp $KERNEL_IMG $ANYKERNEL_DIR
mkdir -p $UPLOAD_DIR
cd $ANYKERNEL_DIR
zip -r9 UPDATE-AnyKernel3.zip * -x README UPDATE-AnyKernel3.zip
mv $ANYKERNEL_DIR/UPDATE-AnyKernel3.zip $UPLOAD_DIR/$FINAL_ZIP
}

# Options
function options() {
echo -e "$cyan***********************************************"
  echo "          Compiling $KERNEL_NAME kernel                  "
  echo -e "***********************************************$nocol"
  echo -e " "
  echo -e " Select one of the following types of build : "
  echo -e " 1.Dirty"
  echo -e " 2.Clean"
  echo -e " 3.Menuconfig"
  echo -n " Your choice : ? "
  read ch

  echo -e " Select if you want zip or just kernel : "
  echo -e " 1.Get flashable zip"
  echo -e " 2.Get kernel only"
  echo -n " Your choice : ? "
  read ziporkernel

case $ch in
  1) echo -e "$cyan***********************************************"
     echo -e "          	Dirty          "
     echo -e "***********************************************$nocol"
     make_kernel ;;
  2) echo -e "$cyan***********************************************"
     echo -e "          	Clean          "
     echo -e "***********************************************$nocol"
     #make clean CC=clang O=output/
     #make mrproper CC=clang O=output/
     make clean O=output/
     make mrproper O=output/
     make_kernel ;;
  3) echo -e "$cyan***********************************************"
     echo -e "          	Menuconfig     "
     echo -e "***********************************************$nocol"
     config_kernel ;;
esac

if [ "$ziporkernel" = "1" ]; then
     echo -e "$cyan***********************************************"
     echo -e "     Making flashable zip        "
     echo -e "***********************************************$nocol"
     make_zip
else
     echo -e "$cyan***********************************************"
     echo -e "     Building Kernel only        "
     echo -e "***********************************************$nocol"
fi
}

# Clean Up
function cleanup(){
rm -rf $ANYKERNEL_DIR/Image.gz-dtb
}

options
cleanup
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"

