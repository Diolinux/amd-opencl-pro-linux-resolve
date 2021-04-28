# AMD OpenCL PRO on Linux (DaVinci Resolve/Blender)

This is a Shell Script to install AMD OpenCL PRO over Mesa Driver originally created by "Kytulendu" https://gist.github.com/kytulendu/3351b5d0b4f947e19df36b1ea3c95cbe

I'm adding here some extra steps to unsure the users will have amdgpu-pro OpenCL working OK over Mesa Driver.

- This was tested on Pop!\_OS 20.04 (AMD/Intel ISO) with DaVinci Resolve 17 Beta,
- Ryzen 7 2700X and RX580 8GB

## What you need?

For better compatibility, install this packages and create a symbolic link:

`sudo apt install opencl-headers ocl-icd-libopencl1 clinfo`

`sudo ln -s /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 /usr/lib/libOpenCL.so`

## Next Step,installing only OpenCL coming from AMDGPU-PRO Driver

1. Download this Repository using git or your browser; ([Or Click Here](https://github.com/Diolinux/amd-opencl-pro-linux-resolve/blob/main/install-opencl-amd.sh))
2. Ensure the file have permissions to "run as a program"(right click over the file, going into properties and checking the box";
3. Open the terminal on the folder were you have download this shell script and run the commando with 'sudo':

`sudo ./install-opencl-amd.sh`

if you get `'sudo: ./install-opencl-amd.sh: command not found'` output, make sure the install script file has all permissions.
To set all permissions run: `sudo chmod a+x ./install-opencl-amd.sh`

You may receive some error messages because we ain't installing the full AMDGPU-PRO, but it should work for DaVinci Resolve, Blender and other applications
that need OpenCL.

Credits to @rra_krr on Twitter.

Hope it helps, thanks.
