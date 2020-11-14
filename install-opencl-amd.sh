#!/bin/bash

# This script will install AMDGPU-PRO OpenCL and Vulkan support.
#
# For Ubuntu and it's flavor, just install the package using this command
# in extracted driver directory instread.
#
#     ./amdgpu-pro-install --opencl=legacy,pal --headless --no-dkms
#
# For Arch Linux or Manjaro, use the opencl-amd on AUR instread.
#
# To use amdvlk driver, launch the program/game with this command :
#
#     VK_ICD_FILENAMES="/opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd64.json" game64
#
# If the program/game is 32bit, use this command :
#
#     VK_ICD_FILENAMES="/opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd32.json" game32
#

prefix='amdgpu-pro'
# amdgpu-pro package version
major='20'
minor='40'
build='1147286'
system='ubuntu-20.04'
# libdrm-amdgpu-amdgpu1 version
libdrmver='2.4.100'
libamd_comgrver='1.7.0'
shared32="/opt/amdgpu-pro/lib/i386-linux-gnu"
shared64="/opt/amdgpu-pro/lib/x86_64-linux-gnu"
ids="/opt/amdgpu/share/libdrm"
vk_icd="/opt/amdgpu-pro/etc/vulkan/icd.d"

# make sure we’re running with root permissions.
if [ `whoami` != root ]; then
    echo Please run this script using sudo
    exit
fi

# check for 64-bit arch
if [ $(uname -m) != 'x86_64' ]; then
    echo This install script support only 64-bit linux. 
    exit
fi

# download and extract drivers
rm -r ${prefix}-${major}.${minor}-${build}-${system} &>/dev/null

if [ ! -f ./${prefix}-${major}.${minor}-${build}-${system}.tar.xz ]; then
    wget --referer https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-40 https://drivers.amd.com/drivers/linux/${prefix}-${major}.${minor}-${build}-${system}.tar.xz
fi

tar xJf ${prefix}-${major}.${minor}-${build}-${system}.tar.xz

cd ${prefix}-${major}.${minor}-${build}-${system}

echo Extracting AMDGPU-PRO OpenCL driver files...
ar x "../${prefix}-${major}.${minor}-${build}-${system}/libdrm-amdgpu-amdgpu1_${libdrmver}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/libdrm-amdgpu-amdgpu1_${libdrmver}-${build}_i386.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/libdrm-amdgpu-common_1.0.0-${build}_all.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/vulkan-amdgpu-pro_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/vulkan-amdgpu-pro_${major}.${minor}-${build}_i386.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-amdgpu-pro-comgr_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-amdgpu-pro-dev_${major}.${minor}-${build}_amd64.deb"
#tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-amdgpu-pro-icd_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-orca-amdgpu-pro-icd_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-orca-amdgpu-pro-icd_${major}.${minor}-${build}_i386.deb"
tar xJf data.tar.xz

# Remove target directory
echo Remove target directory.
rm -r /opt/amdgpu &>/dev/null
rm -r /opt/amdgpu-pro &>/dev/null

# Create target directory
echo Create target directory.
mkdir -p ${ids}
mkdir -p ${shared32}
mkdir -p ${shared64}
mkdir -p ${vk_icd}

echo Patch and installing AMDGPU-PRO OpenCL driver...

rm /etc/OpenCL/vendors/amdocl-orca64.icd
rm /etc/OpenCL/vendors/amdocl-orca32.icd
rm /etc/OpenCL/vendors/amdocl64.icd

# For some reasons this directory is not exist on some system
if [ ! -f /etc/OpenCL/vendors ]; then
    echo Directory /etc/OpenCL/vendors is not exist
    echo Creating it...
    mkdir -p /etc/OpenCL/vendors
fi
cp ./etc/OpenCL/vendors/*.icd /etc/OpenCL/vendors

cp ./opt/amdgpu-pro/etc/vulkan/icd.d/*.json ${vk_icd}
cp ./opt/amdgpu/share/libdrm/amdgpu.ids /opt/amdgpu/share/libdrm

pushd ./opt/amdgpu/lib/i386-linux-gnu &>/dev/null
rm "libdrm_amdgpu.so.1"
mv "libdrm_amdgpu.so.1.0.0" "libdrm_amdpro.so.1.0.0"
ln -s "libdrm_amdpro.so.1.0.0" "libdrm_amdpro.so.1"
mv "libdrm_amdpro.so.1.0.0" "${shared32}"
mv "libdrm_amdpro.so.1" "${shared32}"
popd &>/dev/null

pushd ./opt/amdgpu/lib/x86_64-linux-gnu &>/dev/null
rm "libdrm_amdgpu.so.1"
mv "libdrm_amdgpu.so.1.0.0" "libdrm_amdpro.so.1.0.0"
ln -s "libdrm_amdpro.so.1.0.0" "libdrm_amdpro.so.1"
mv "libdrm_amdpro.so.1.0.0" "${shared64}"
mv "libdrm_amdpro.so.1" "${shared64}"
popd &>/dev/null

pushd ./opt/amdgpu-pro/lib/i386-linux-gnu &>/dev/null
sed -i "s|libdrm_amdgpu|libdrm_amdpro|g" libamdocl-orca32.so
mv "libamdocl-orca32.so" "${shared32}"
mv "libamdocl12cl32.so" "${shared32}"
mv "amdvlk32.so" "${shared32}"
popd &>/dev/null

pushd ./opt/amdgpu-pro/lib/x86_64-linux-gnu &>/dev/null
rm "libamd_comgr.so"
sed -i "s|libdrm_amdgpu|libdrm_amdpro|g" libamdocl-orca64.so
mv "libamdocl-orca64.so" "${shared64}"
mv "libamdocl12cl64.so" "${shared64}"
mv "libamd_comgr.so.${libamd_comgrver}" "${shared64}"
ln -s "libamd_comgr.so.${libamd_comgrver}" "libamd_comgr.so"
mv "libamd_comgr.so" "${shared64}"
mv "libamdocl64.so" "${shared64}"
#mv "libcltrace.so" "${shared64}"
mv "amdvlk64.so" "${shared64}"
popd &>/dev/null

echo "# AMDGPU-PRO OpenCL support" > zz_amdgpu-pro_x86_64.conf
echo "/opt/amdgpu-pro/lib/x86_64-linux-gnu" >> zz_amdgpu-pro_x86_64.conf
cp zz_amdgpu-pro_x86_64.conf /etc/ld.so.conf.d/
echo "# AMDGPU-PRO OpenCL support" > zz_amdgpu-pro_x86.conf
echo "/opt/amdgpu-pro/lib/i386-linux-gnu" >> zz_amdgpu-pro_x86.conf
cp zz_amdgpu-pro_x86.conf /etc/ld.so.conf.d/
ldconfig

echo "Finished!"

cd ..
echo "Cleaning up"
rm -r ${prefix}-${major}.${minor}-${build}-${system}

#just in case
rm /opt/amdgpu-pro/lib/i386-linux-gnu/libdrm_amdgpu.so.1 &>/dev/null
rm /opt/amdgpu-pro/lib/i386-linux-gnu/libdrm_amdgpu.so.1.0.0 &>/dev/null
rm /opt/amdgpu-pro/lib/x86_64-linux-gnu/libdrm_amdgpu.so.1 &>/dev/null
rm /opt/amdgpu-pro/lib/x86_64-linux-gnu/libdrm_amdgpu.so.1.0.0 &>/dev/null

echo Done.