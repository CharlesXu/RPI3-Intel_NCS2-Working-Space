
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

echo "Testing and examples"
cd ~
mkdir openvino && cd openvino
workon openvino

# Example 1: face detection
wget --no-check-certificate https://download.01.org/opencv/2019/open_model_zoo/R1/models_bin/face-detection-adas-0001/FP16/face-detection-adas-0001.bin
wget --no-check-certificate https://download.01.org/opencv/2019/open_model_zoo/R1/models_bin/face-detection-adas-0001/FP16/face-detection-adas-0001.xml
wget "https://images.pexels.com/photos/1308783/pexels-photo-1308783.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940" -O pexels-photo.jpg
wget https://github.com/cyrilwang/ncs_python_samples/raw/master/openvino_face_detector.py
python openvino_face_detector.py --config face-detection-adas-0001.xml --model face-detection-adas-0001.bin --image pexels-photo.jpg

# Example 2: object detection
wget https://github.com/chuanqi305/MobileNet-SSD/raw/master/mobilenet_iter_73000.caffemodel
wget https://github.com/chuanqi305/MobileNet-SSD/raw/master/deploy.prototxt
wget https://www.pexels.com/video/1246169/download/ -O pexels-video.mp4
wget https://raw.githubusercontent.com/cyrilwang/ncs_python_samples/master/real_time_object_detection.py
python real_time_object_detection.py --config deploy.prototxt --model mobilenet_iter_73000.caffemodel --video pexels-video.mp4
