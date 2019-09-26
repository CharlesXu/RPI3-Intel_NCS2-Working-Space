#!/bin/bash
# This is the script to install OpenCV on Raspberry Pi 3, and run OpenCV with OpenVino
# Requirement:
#  - Raspberry Pi 3 (Linux raspberrypi 4.19.66-v7+ #1253 SMP Thu Aug 15 11:49:46 BST 2019 armv7l GNU/Linux)
#  - Intel Neural Compute Stick 2
# Reference: 
#  - https://blog.everlearn.tw/ai/%E5%9C%A8-raspberry-pi-3-model-b-%E5%AE%89%E8%A3%9D-openvino-%E8%88%87-opencv-2-2


echo "install pip and virtual environment"
cd ~
sudo wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip install virtualenv virtualenvwrapper
sudo rm -rf get-pip.py ~/.cache/pip

echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
echo "export WORKON_HOME=$HOME/.virtualenvs" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
source ~/.bashrc

echo "Build a virtual environment for the installation"
mkvirtualenv openvino -p python3

echo "Install required Python packages"
pip install numpy picamera imutils

echo "Install OpenCV in the virtual environment"
cd ~/.virtualenvs/openvino/lib/python3.5/site-packages/
ln -s /opt/intel/openvino/python/python3.5/cv2.cpython-35m-arm-linux-gnueabihf.so cv2.so

# to double check whether OpenCV is correctly linked
python -c "import cv2;print(cv2.__version__)"

####################################
# Running the examples
####################################

echo "Testing and examples"
cd ~
if [ ! -d openvino ]; then
  mkdir openvino && cd openvino
else
  cd openvino
fi
workon openvino

# Example 1: face detection
# in case there is "Global Mutex Initialization Failed" error message, please run "sudo rm /tmp/mvnc.mutex" to fix the problem
wget --no-check-certificate https://download.01.org/opencv/2019/open_model_zoo/R1/models_bin/face-detection-adas-0001/FP16/face-detection-adas-0001.bin
wget --no-check-certificate https://download.01.org/opencv/2019/open_model_zoo/R1/models_bin/face-detection-adas-0001/FP16/face-detection-adas-0001.xml
wget "https://images.pexels.com/photos/1308783/pexels-photo-1308783.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940" -O pexels-photo.jpg
wget https://github.com/cyrilwang/ncs_python_samples/raw/master/openvino_face_detector.py
python openvino_face_detector.py --config face-detection-adas-0001.xml --model face-detection-adas-0001.bin --image pexels-photo.jpg

# Example 2: object detection
wget https://github.com/chuanqi305/MobileNet-SSD/raw/master/mobilenet_iter_73000.caffemodel
wget https://github.com/chuanqi305/MobileNet-SSD/raw/master/deploy.prototxt -O deploy.prototxt.object_detection
wget https://www.pexels.com/video/1246169/download/ -O pexels-video.mp4
wget https://raw.githubusercontent.com/cyrilwang/ncs_python_samples/master/real_time_object_detection.py
python real_time_object_detection.py --config deploy.prototxt --model mobilenet_iter_73000.caffemodel --video pexels-video.mp4
# if you want to test with real time video, you can try this
python real_time_object_detection.py --config deploy.prototxt.object_detection --model mobilenet_iter_73000.caffemodel

# Example 3: age detection
wget https://raw.githubusercontent.com/opencv/opencv/master/samples/dnn/face_detector/deploy.prototxt 
wget https://github.com/opencv/opencv_3rdparty/raw/dnn_samples_face_detector_20170830/res10_300x300_ssd_iter_140000.caffemodel
wget https://download.01.org/openvinotoolkit/2018_R5/open_model_zoo/age-gender-recognition-retail-0013/FP16/age-gender-recognition-retail-0013.xml
wget https://download.01.org/openvinotoolkit/2018_R5/open_model_zoo/age-gender-recognition-retail-0013/FP16/age-gender-recognition-retail-0013.bin
wget https://raw.githubusercontent.com/cyrilwang/ncs_python_samples/master/realtime_age_gender_detection.py
wget 'https://gcs-vimeo.akamaized.net/exp=1560369175~acl=%2A%2F1239378998.mp4%2A~hmac=2dd5f51631ecb17b571650610c53f53ec31c3d9685f55b1ac721e68fab1f971d/vimeo-prod-skyfire-std-us/01/3915/12/319576224/1239378998.mp4?download=1&filename=Pexels+Videos+1959209.mp4' -O sample.mp4
python realtime_age_gender_detection.py --target vpu --video sample.mp4
# if you want to test with real time video, you can try this
python realtime_age_gender_detection.py --target vpu
