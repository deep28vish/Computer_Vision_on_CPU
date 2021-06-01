#!/bin/bash
# chmod +x ./person_bike_vehicle_detection_v2.sh
#while getopts i:a:f: flag
while getopts :i:I: flag; do
    case "${flag}" in
        i) LOCATION=${OPTARG};;
	I) LOCATION=${OPTARG};;
#	h) echo "TEST" ;; TODO Passing help
    esac
done

##################################################################################
##################################################################################
source /opt/intel/openvino_2021/bin/setupvars.sh 
##################################################################################
echo "##############################################################################"
echo "# Path to Me --------------->  ${PWD}     "
echo "# Parent Path -------------->  ${0%/*}  "
echo "# My Name ------------------>  ${0##*/} "

echo "##############################################################################"
echo "#                       #           #               ^                        #"
echo "##                    #   #       #   #           ^   ^                     ##"
echo "###                 #       # @ #       #                                  ###"
echo "####              #           #           #                               ####"
###################################################################################
LOCATION=traffic_cam_intel.mp4
###################################################################################
DETECTION_MODEL=model_intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
DETECTION_MODEL_PROC=model_proc/person-vehicle-bike-detection-crossroad-0078.json
###################################################################################
TRACK="queue ! gvatrack tracking-type=short-term ! queue"
###################################################################################
DEVICE=CPU
THRESHOLD=0.75
INFRENCE_INTERVAL=1
###################################################################################
SINK_ELEMENT="videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=xvimagesink sync=false"
#SINK_ELEMENT="videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=ximagesink sync=false"
#SINK_ELEMENT="videoconvert ! gvafpscounter ! fpsdisplaysink video-sink=autovideosink sync=false"
###################################################################################
PIPELINE="gst-launch-1.0 filesrc location=${LOCATION} ! decodebin ! gvadetect model=${DETECTION_MODEL} model-proc=${DETECTION_MODEL_PROC} device=${DEVICE} threshold=${THRESHOLD} inference-interval=${INFRENCE_INTERVAL} nireq=4 ! ${TRACK} ! queue ! gvawatermark ! ${SINK_ELEMENT}"
###################################################################################
echo "##############################################################################"
echo "PERSON VEHICLE BIKE DETECTION AND TRACKING"
echo "VIDEO NAME :::" ${LOCATION}
echo "MODEL NAME :::" ${DETECTION_MODEL}
echo "DEVICE :::" ${DEVICE}
echo "THRESHOLD :::" ${THRESHOLD}
echo "##############################################################################"
echo "GST PIPELINE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo ${PIPELINE}
echo "##############################################################################"
seconds=2; date1=$((`date +%s` + $seconds)); 
while [ "$date1" -ge `date +%s` ]; do 
  echo -ne "PIPELINE ROLLS IN ::----------->>>$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r"; 
done
${PIPELINE}
echo "##############################################################################"

