#!/bin/bash
# This is the script to install OpenVino on Raspberry Pi 3.
# Requirement:
#  - Raspberry Pi 3 (Linux raspberrypi 4.19.66-v7+ #1253 SMP Thu Aug 15 11:49:46 BST 2019 armv7l GNU/Linux)
#  - Intel Neural Compute Stick 2
# Reference: 
#  - https://software.intel.com/en-us/articles/OpenVINO-Install-RaspberryPI
#  - https://github.com/yehengchen/FaceTracking-NCS-RPI3/blob/master/Install_openvino.sh
#  - https://blog.everlearn.tw/ai/%E5%9C%A8-raspberry-pi-3-model-b-%E5%AE%89%E8%A3%9D-openvino-%E8%88%87-opencv-1-2#ftoc-heading-10

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install libjpeg-dev libpng-dev libtiff5-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev
sudo apt-get install cmake libgtk-3-dev libcanberra-gtk*
sudo apt-get install libatlas-base-dev gfortran
sudo apt-get install vim

echo "download and install OpenVino"
cd /opt
sudo mkdir -p intel
cd intel
sudo wget https://download.01.org/opencv/2019/openvinotoolkit/R1/l_openvino_toolkit_raspbi_p_2019.1.144.tgz
sudo tar xf l_openvino_toolkit_raspbi_p_2019.1.144.tgz
sudo mv inference_engine_vpu_arm openvino

echo "Setting installation directory path..."
sudo sed -i "s|<INSTALLDIR>|/opt/intel/openvino|" /opt/intel/openvino/bin/setupvars.sh
source /opt/intel/openvino/bin/setupvars.sh
echo "source /opt/intel/openvino/bin/setupvars.sh" >> ~/.bashrc

echo "Setting up USB rules..."
sudo usermod -a -G users "$(whoami)"
echo "Activate Neural Stick 2 USB usage..."
sh /opt/intel/openvino/install_dependencies/install_NCS_udev_rules.sh

sudo su -
cd /opt/intel/openvino
source bin/setupvars.sh
sh /opt/intel/openvino/install_dependencies/install_NCS_udev_rules.sh

## increase the swap memory size from 100 to 2048
#sudo sed -i "s|CONF_SWAPSIZE=100|CONF_SWAPSIZE=2048|" /etc/dphys-swapfile
#sudo systemctl stop dphys-swapfile
#sudo systemctl start dphys-swapfile

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-march=armv7-a" /opt/intel/openvino/deployment_tools/inference_engine/samples
make -j2 object_detection_sample_ssd

## reduce the swap memory size from 2048 to the default value
#sudo sed -i "s|CONF_SWAPSIZE=2048|CONF_SWAPSIZE=100|" /etc/dphys-swapfile
#sudo systemctl stop dphys-swapfile
#sudo systemctl start dphys-swapfile

# test OpenVino
wget --no-check-certificate https://download.01.org/opencv/2019/open_model_zoo/R1/models_bin/face-detection-adas-0001/FP16/face-detection-adas-0001.bin
wget --no-check-certificate https://download.01.org/opencv/2019/open_model_zoo/R1/models_bin/face-detection-adas-0001/FP16/face-detection-adas-0001.xml
wget "https://images.pexels.com/photos/1308783/pexels-photo-1308783.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940" -O pexels-photo.jpg
./armv7l/Release/object_detection_sample_ssd -m face-detection-adas-0001.xml -d MYRIAD -i pexels-photo.jpg

# The output file is "out_0.bmp" under the folder "/opt/intel/openvino/build"


