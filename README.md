# COMPUTER VISION ON CPU

This Git hub repo will allow you to run Computer vision model on your INTEL based system(laptop/pc/workstation/server) with Linux OS 18.04 LTS. Follow the below mentioned article for in-depth explanation, this is a quick guide with easy to follow steps and will get you up and running within 10 mins(assuming good internet speed).

***

> By the end you will be running Multiple Object Detection, Tracking, Classification on People and Vehciles at 30+ FPS on your CPU only. 
***
![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/sample.png)

Article - 

Also Read [Computer Vision on GPU](https://vdeepvision.medium.com/computer-vision-ai-in-production-using-nvida-deepstream-6c90d3daa8a5) , to learn how to deploy COMPUTER VISION model on NVIDIA GPU in 5 mins.

#### Requirements:
* INTEL CPU 
* LINUX 18.04 LTS
* DOCKER
* Minimum 15 GB HDD
* Minimum 4 GB RAM

### Docker Installation
[Docker Installation](https://docs.docker.com/engine/install/ubuntu/)

```bash
sudo apt-get update

sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic test"

sudo apt update

sudo apt install docker-ce

```
To confirm Docker installation
```
kuk@kuk:~$ docker -v
Docker version 20.10.6, build 370c289
```


#### Getting GIT repository
Open Terminal and move to 'Documents' folder and follow clone this repository.

```bash
git clone git clone https://github.com/deep28vish/Computer_Vision_on_CPU.git
```


### OPENVINO DOCKER IMAGE
Now that we have docker , we will download the INTEL OPENVINO container. and since we have our repository at 'Documents' we will mount the same.
Read more about OPENVINO [here](https://docs.openvinotoolkit.org/latest/index.html)

**STEP 1)** Download openvino IMAGE and run container with name 'opv1'. 

**STEP 1-A)**


```bash
sudo docker run -it -e DISPLAY=$DISPLAY --network=host -d --name opv1 -v $HOME/Desktop/cv_on_cpu/:/home/ --privileged --user root openvino/ubuntu18_data_dev 

```
The above command will post a message that the it was unable to find the 'openvino/ubuntu18_data_dev ' locally and will start downloading 8.58 GB of container, this is a one time process. 



**STEP 1-B)** - After downloading we can check IMAGE by: 
```bash
kuk@kuk:~$ sudo docker images 
[sudo] password for kuk: 
REPOSITORY                                 TAG                   IMAGE ID       CREATED         SIZE
openvino/ubuntu18_data_dev                 latest                4765154f523   2 months ago    8.58GB
```
* 'openvino/ubuntu18_data_dev' means we have openvino container which is running with name 'opv1'
* You will have your own unique 'IMAGE ID'

**STEP 1-C)** -To check for CONTAINER: 

```bash

kuk@kuk:~$ sudo docker ps
CONTAINER ID   IMAGE                        COMMAND       CREATED        STATUS         PORTS     NAMES
8a1727f0861e   openvino/ubuntu18_data_dev   "/bin/bash"   24 hours ago   Up 3 seconds             opv1
```
Now we have a container named 'opv1' which is made out of IMAGE 'openvino/ubuntu18_data_dev'. And as we can see the container is running. We will get inside the container to run our mode.


**STEP 2)** - Accessing the container.

**STEP 2-A)** - To see the VIDEO OUT, we need to grant some permissions by: 
```bash
kuk@kuk:~$ xhost +
access control disabled, clients can connect from any host
```
* Run the above command before getting inside the container. (- once - when system restarts)

**STEP 2-B)**  Accessing the container: 
```bash
sudo docker exec -it --workdir /home --user root opv1 bash
```
Output:
```kuk@kuk:~$ sudo docker exec -it --workdir /home --user root opv1 bash
[setupvars.sh] OpenVINO environment initialized
root@kuk:/home# 
```

**STEP 2-C)** - We are now inside the container, check the list by:
```bash
root@kuk:/home# ls
adv_detection_tracking_classification.sh            only_detection_track_person_car_classify_two_v3.sh  only_detection_track_v2.sh  read_me_v1
model_intel                                         only_detection_track_person_classify_one_v1.sh      only_detection_track_v3.sh  traffic_cam_intel.mp4
model_proc                                          only_detection_track_person_classify_one_v2.sh      only_detection_v1.sh
only_detection_track_person_car_classify_two_v1.sh  only_detection_track_person_classify_one_v3.sh      only_detection_v2.sh
only_detection_track_person_car_classify_two_v2.sh  only_detection_track_v1.sh                          only_detection_v3.sh
```
* As we mounted the contents of cv_on_cpu from Documents folder, we can see the same here.

***
IF you are not able to get inside the container by *STEP 2-B)* , and face this error:
```
kuk@kuk:~$ sudo docker exec -it --workdir /home --user root opv1 bash
Error response from daemon: Container 8a1727f0861ed75a77373556e56fde789dh0393cd285e85159680046450fef936cc is not running
```
That means you might have restarted your machine and your container is stoppped, to start the container 1st check its availability by *STEP 1-C)* and is it shows an empty row meaning you need to start your container by:

**STEP 2-D)**
```bash
kuk@kuk:~$ sudo docker start opv1
opv1

```
Now by running *STEP 1-C)* again you will able to see the container running. And now lets continue to running the **Computer Vision model**.

### DL-STREAMER

Gstreamer is an oldschool video management application and is made up of component blocks called as plugins/elements, INTEL has developed its own set of plugins/elements that can be easily used with Gstreamer and this conjugate environment is called [DL-STREAMER](https://github.com/openvinotoolkit/dlstreamer_gst). More about intel plugins/elements [here](https://github.com/openvinotoolkit/dlstreamer_gst/wiki/Elements).

**STEP 3-A)**  - To  check for plugins/elements:


 ```ini
root@kuk:/home# gst-inspect-1.0 | grep gva

gvaitttracer:  gvaitttracer (GstTracerFactory)
gvatrack:  gvatrack: Object tracker (generates GstGvaObjectTrackerMeta, GstVideoRegionOfInterestMeta)
audioanalytics:  gvaaudiodetect: Audio event detection based on input audio
videoanalytics:  gvametaaggregate: Meta Aggregate
videoanalytics:  gvametapublish: Generic metadata publisher
videoanalytics:  gvafpscounter: Frames Per Second counter
videoanalytics:  gvawatermark: Labeler of detection/classification/recognition results
videoanalytics:  gvametaconvert: Metadata converter
videoanalytics:  gvaclassify: Object classification (requires GstVideoRegionOfInterestMeta on input)
videoanalytics:  gvadetect: Object detection (generates GstVideoRegionOfInterestMeta)
videoanalytics:  gvainference: Generic full-frame inference (generates GstGVATensorMeta)
gvapython:  gvapython: Python callback provider

```
**gvadetect,gvatrack,gvaclassify,gvawatermark** are some of the elements we will need to run the pipeline. You may get bunch of WARNING** before getting the above list , ignore the warning and make sure gva elements are present in your list.

**DISCLAIMER** :- We have 3 versions of each variation of 4 types of Computer Vision models i.e. 12 files. Each version is having different type of SINK element (gst-element) namely - **xvimagesink, ximagesink and autovideosink.** 

**STEP 3-B)** - Run the below line to check which of the 3 sinks mentioned above are working for you, you may get result in all 3 or just one. IF you are not getting output in any sink you need to try *STEP 2-A)* again to give display access to container.

 **V1** - *xvimagesink*
```bash
gst-launch-1.0 -v videotestsrc pattern=snow ! video/x-raw,width=1280,height=720 ! xvimagesink 
```
**V2** - *ximagesink*
```bash
gst-launch-1.0 -v videotestsrc pattern=snow ! video/x-raw,width=1280,height=720 ! ximagesink 
```

**V3** - *autovideosink*
```bash
gst-launch-1.0 -v videotestsrc pattern=snow ! video/x-raw,width=1280,height=720 ! autovideosink
```

![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/test_src.png)

If all three VERSIONS are working for you feel free to use any version .sh file as you wish. But if suppose only V2 is giving the output , you must use all the .sh files with v2 versions.

INTEL uses *XML & BIN* file along with *proc* files , all the required files are stored in this repository under model_intel & model_proc. The pipelines are the one responsible for running inference on the video and all the .sh file present will run a pipeline but have easy to understand format, which you can edit and try new possibilities.

### Running Inference on CPU via DL-STREAMER

* **STEP 4-A)** - Only Detection , class - Person, Vehicle , Bike on video at 30+fps on CPU only. We are going here with V1 here in examples, you must go with what ever version works for you. ```./only_detection_v1.sh``` 

```ini

root@kuk:/home# ./only_detection_v1.sh 
ONLY DETECTION
[setupvars.sh] OpenVINO environment initialized
##############################################################################
# Path to Me --------------->  /home     
# Parent Path -------------->  .  
# My Name ------------------>  only_detection_v1.sh 
##############################################################################
#                       #           #               ^                        #
##                    #   #       #   #           ^   ^                     ##
###                 #       # @ #       #                                  ###
####              #           #           #                               ####
##############################################################################
PERSON VEHICLE BIKE DETECTION
VIDEO NAME ::: traffic_cam_intel.mp4
MODEL NAME ::: model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
DEVICE ::: CPU
THRESHOLD ::: 0.75
##############################################################################
GST PIPELINE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false
##############################################################################
PIPELINE ROLLS IN ::----------->>>23:59:59
(gst-plugin-scanner:4769): GStreamer-WARNING **: 
(gst-plugin-scanner:4769): GStreamer-WARNING **: 

Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
Redistribute latency...
Redistribute latency...
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
FpsCounter(1sec): total=41.85 fps, number-streams=1, per-stream=41.85 fps

```

![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/only_detection_v1.png)

* **STEP 4-B)** - Detection and Tracking for Person, Vehicle, Bike , every object will be assigned a unique tracking number. ```./only_detection_track_v1.sh``` 

```ini
root@kuk:/home# ./only_detection_track_v1.sh 
[setupvars.sh] OpenVINO environment initialized
##############################################################################
# Path to Me --------------->  /home     
# Parent Path -------------->  .  
# My Name ------------------>  only_detection_track_v1.sh 
##############################################################################
#                       #           #               ^                        #
##                    #   #       #   #           ^   ^                     ##
###                 #       # @ #       #                                  ###
####              #           #           #                               ####
##############################################################################
PERSON VEHICLE BIKE DETECTION AND TRACKING
VIDEO NAME ::: traffic_cam_intel.mp4
MODEL NAME ::: model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
DEVICE ::: CPU
THRESHOLD ::: 0.75
##############################################################################
GST PIPELINE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvatrack tracking-type=short-term ! queue ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false
##############################################################################
PIPELINE ROLLS IN ::----------->>>23:59:59
(gst-plugin-scanner:6295): GStreamer-WARNING **: 1

(gst-plugin-scanner:6295): GStreamer-WARNING **: 
Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
Redistribute latency...
Redistribute latency...
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
FpsCounter(1sec): total=28.59 fps, number-streams=1, per-stream=28.59 fps
```

![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/only_detection_track_v1.png)

* **STEP 4-C)** - Detection , Tracking and classification of person attributes such as :*"MALE:","FEMLAE:","has_bag","has_backpack","has_hat","has_longsleeves",       "has_longpants","has_longhair","has_coat_jacket"* ```./only_detection_track_person_classify_one_v1.sh``` 

```ini
root@kuk:/home# ./only_detection_track_person_classify_one_v1.sh 
[setupvars.sh] OpenVINO environment initialized
##############################################################################
# Path to Me --------------->  /home     
# Parent Path -------------->  .  
# My Name ------------------>  only_detection_track_person_classify_one_v1.sh 
##############################################################################
#                       #           #               ^                        #
##                    #   #       #   #           ^   ^                     ##
###                 #       # @ #       #                                  ###
####              #           #           #                               ####
##############################################################################
PERSON VEHICLE BIKE DETECTION, TRACKING AND PERSON ATTRIBUTE CLASSIFICATION 
VIDEO NAME ::: traffic_cam_intel.mp4
MODEL NAME ::: model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
DEVICE ::: CPU
THRESHOLD ::: 0.75
##############################################################################
GST PIPELINE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP32/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=1 device=CPU object-class=person ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false
##############################################################################
PIPELINE ROLLS IN ::----------->>>00:00:00
(gst-plugin-scanner:6939): GStreamer-WARNING **: 

(gst-plugin-scanner:6939): GStreamer-WARNING **: 
Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
Redistribute latency...
Redistribute latency...
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
FpsCounter(1sec): total=29.42 fps, number-streams=1, per-stream=39.42 fps
```
![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/only_detection_track_person_classify_one_v1.png)

* **STEP 4-D)** - Detection, tracking and classification on person attributes and vehicle. Person attributes same as mentioned in *STEP 4-C)* and vehicles attributes like: 

* COLOR :"white","gray","yellow","red","green","blue","black".

* Vehicle Type:  "car","van","truck","bus"

```./only_detection_track_person_car_classify_two_v1.sh```


```ini

root@kuk:/home# ./only_detection_track_person_car_classify_two_v1.sh
[setupvars.sh] OpenVINO environment initialized
##############################################################################
# Path to Me --------------->  /home     
# Parent Path -------------->  .  
# My Name ------------------>  only_detection_track_person_car_classify_two_v1.sh 
##############################################################################
#                       #           #               ^                        #
##                    #   #       #   #           ^   ^                     ##
###                 #       # @ #       #                                  ###
####              #           #           #                               ####
##############################################################################
PERSON VEHICLE BIKE DETECTION, TRACKING AND PERSON ATTRIBUTE CLASSIFICATION 
VIDEO NAME ::: traffic_cam_intel.mp4
MODEL NAME ::: model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
DEVICE ::: CPU
THRESHOLD ::: 0.75
##############################################################################
GST PIPELINE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP32/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=1 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false
##############################################################################
PIPELINE ROLLS IN ::----------->>>23:59:59
(gst-plugin-scanner:7712): GStreamer-WARNING **: 
(gst-plugin-scanner:7712): GStreamer-WARNING **: 
Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
Redistribute latency...
Redistribute latency...
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
FpsCounter(1sec): total=30.85 fps, number-streams=1, per-stream=30.85 fps

```
![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/only_detection_track_person_car_classify_two_v1.png)
* **STEP 4-E)** - 
This is all achieved via collaboration between INTEL ELEMENTS and GST ELEMENTS. Upon running the above models you might see 99%-100% CPU USAGE to control this and tweak some parameters there is another .sh file ```./adv_detection_tracking_classification.sh``` run this file and you might have somewhat different CPU stats. Explore the files and pipelines to make the best out of it.

![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/adv_detection_tracking_classification.png)

* **STEP 4-F)** - ```./adv_detection_tracking_classification_lite.sh```  is the LITE version unlike above given model this one uses the *INT8* weights and is therefore faster than conventional *FP32* which we have been using so far. It is also a bit easy on CPU cores and can give you up to 60+ FPS on 6 core machine.
 
![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/adv_detection_tracking_classification_lite.png)

* **STEP 4-G)** - ```./multiple_adv_detection_tracking_classification_lite.sh``` This pipeline is to demonstrate the infrence on multiple sources.

***

### License Plate Detection Demo
INTEL has lot many models in its artillery which you can find [here](https://github.com/openvinotoolkit/open_model_zoo/blob/master/models/intel/index.md). And still if you need to use your own model based on YOLOv3, SSD or any such famous architecture you can follow [this](https://docs.openvinotoolkit.org/latest/openvino_docs_get_started_get_started_linux.html) guide. Remeber you need *IR -  Intermediate Representation* format to run the inference. Just chnage the path in DL_pipeline as given above and you are good to go.

![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/intel_formats.png)

* **STEP 5-A)** - TO SHOWCASE one such model , we will try running ANPR - AUTOMATIC NUMBER PLATE RECOGNITION.
```bash
root@kuk:/home# /opt/intel/openvino/deployment_tools/demo/demo_security_barrier_camera.sh 
```
After some downloading of required files and IR models and you will see the below image.

![Image](https://github.com/deep28vish/Computer_Vision_on_CPU/blob/master/imgs/anpr.png)

***
***
## SUMMARY - - Follow this for quick run.
Instaliing Docker
```bash
sudo apt-get update

sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic test"

sudo apt update

sudo apt install docker-ce

dokcer -v

cd /home/${USERNAME}/Documents/

git clone https://github.com/deep28vish/Computer_Vision_on_CPU.git
```
To get Docker Container
```bash
sudo docker run -it -e DISPLAY=$DISPLAY --network=host -d --name opv1 -v $HOME/Documents/Computer_Vision_on_CPU/:/home/ --privileged --user root openvino/ubuntu18_data_dev 

xhost +

sudo docker exec -it --workdir /home --user root opv1 bash
```
Inside Docker Container:
```bash
gst-inspect-1.0 | grep gva

gst-launch-1.0 -v videotestsrc pattern=snow ! video/x-raw,width=1280,height=720 ! xvimagesink
```
Pipelines:
* **Detection**: ```gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```
* **Detection+Tracking**: ```gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvatrack tracking-type=short-term ! queue ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```
* **DEtection+Tracking+Classification**: ```gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP32/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=1 device=CPU object-class=person ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```
* **Detection+Tracking+Classificationx2** : ``` gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP32/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=1 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```
* **Advance** : ```gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! qtdemux ! avdec_h264 max_threads=4 ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json threshold=0.75 inference-interval=1 model-instance-id=detect cpu-throughput-streams=4 nireq=1 ie-config=CPU_BIND_THREAD=NO,CPU_THREADS_NUM=16 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP32/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=1 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```
* **Advance_lite**: ```gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! qtdemux ! avdec_h264 max_threads=4 ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP16-INT8/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json threshold=0.75 inference-interval=10 model-instance-id=detect cpu-throughput-streams=4 nireq=1 ie-config=CPU_BIND_THREAD=NO,CPU_THREADS_NUM=16 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP16-INT8/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=10 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```
* **Multiple_streams**: ``` filesrc location=traffic_cam_intel.mp4 ! qtdemux ! avdec_h264 max_threads=4 ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP16-INT8/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json threshold=0.75 inference-interval=10 model-instance-id=detect cpu-throughput-streams=4 nireq=1 ie-config=CPU_BIND_THREAD=NO,CPU_THREADS_NUM=16 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP16-INT8/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=10 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false filesrc location=traffic_4k_edited_1.mp4 ! qtdemux ! avdec_h264 max_threads=4 ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP16-INT8/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json threshold=0.75 inference-interval=10 model-instance-id=detect cpu-throughput-streams=4 nireq=1 ie-config=CPU_BIND_THREAD=NO,CPU_THREADS_NUM=16 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP16-INT8/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=10 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```

#### Running Inference on CCTV 
Get your CCTV RTSP from [here](https://www.getscw.com/decoding/rtsp), and replace the RTSP addr. in the mentioned pipeline.
```gst-launch-1.0 rtspsrc location=rtsp://admin:admin123@192.167.1.72/VideoInput/1/mpeg4/1 latency=100 ! queue ! rtph264depay ! h264parse ! avdec_h264 max_threads=4 ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP16-INT8/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json threshold=0.75 inference-interval=10 model-instance-id=detect cpu-throughput-streams=4 nireq=1 ie-config=CPU_BIND_THREAD=NO,CPU_THREADS_NUM=16 ! queue ! gvatrack tracking-type=short-term ! queue ! gvaclassify model=model_intel/person-attributes-recognition-crossroad-0230/FP16-INT8/person-attributes-recognition-crossroad-0230.xml model-proc=model_proc/person-attributes-recognition-crossroad-0230.json reclassify-interval=10 device=CPU object-class=person ! queue ! gvaclassify model=model_intel/vehicle-attributes-recognition-barrier-0039/FP32/vehicle-attributes-recognition-barrier-0039.xml model-proc=model_proc/vehicle-attributes-recognition-barrier-0039.json reclassify-interval=10 device=CPU object-class=vehicle ! queue ! gvawatermark ! videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false```

#### Saving Output Inf. Video to .mp4
```gst-launch-1.0 filesrc location=traffic_cam_intel.mp4 ! decodebin ! gvadetect model=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml model-proc=model_proc/person-vehicle-bike-detection-crossroad-0078.json device=CPU threshold=0.75 inference-interval=1 nireq=4 ! queue ! gvawatermark ! videoconvert ! x264enc ! mp4mux ! filesink location=traffic_cam_intel_output.mp4```
***
# Extra materials on COMPUTER VISION
> [TensorFlow Object-Detection for Videos onWindows-10](https://medium.com/@deep12vish/tensorflow-object-detection-for-videos-onwindows-10-1c1a9ffd6cac)


> [TensorFlow Object Detection in Windows (under 30 lines)](https://medium.com/@deep12vish/tensorflow-object-detection-in-windows-under-30-lines-d6776586c4ab)


> [Practical aspects to select a Model for Object Detection](https://medium.com/@deep12vish/practical-aspects-to-select-a-model-for-object-detection-c704055ab325)


> [Setting up TensorFlow 1.14 in bare Windows](https://medium.com/@deep12vish/setting-up-tensorflow-1-14-in-bare-windows-adc429ab792c)

### Computer Vision on GPU
> [Computer Vision (AI) in Production using Nvida-DeepStream](https://vdeepvision.medium.com/computer-vision-ai-in-production-using-nvida-deepstream-6c90d3daa8a5)

### GIT HUB Repos
* [Open-CV Perks](https://github.com/deep28vish/openCV-perks)
* [Object-detection-Videos-OpenCV](https://github.com/deep28vish/Object-detection-Videos-OpenCV)
* [Object-Detection-Webcam-OpenCV](https://github.com/deep28vish/Object-Detection-Webcam-OpenCV)
* [TensorFLow-Object_detection-Images-and-Videos-Windows10](https://github.com/deep28vish/TensorFLow-Object_detection-Images-and-Videos-Windows10)
* [DeepStream](https://github.com/deep28vish/DeepStream)

