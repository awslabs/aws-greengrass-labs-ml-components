# DLR image classification

The DLR image classification component (aws.greengrass.DLRImageClassification) contains sample inference code to perform image classification inference using Deep Learning Runtime and resnet-50 models. This component uses the variant DLR image classification model store and the DLR runtime components as dependencies to download DLR and the sample models.

## Operating system

This component can be installed on core devices that run the following operating systems:
- Linux
- Windows


## Requirements

This component has the following requirements:

- On Greengrass core devices running Amazon Linux 2 or Ubuntu 18.04, GNU C Library (glibc) version 2.27 or later installed on the device.

- On Armv7l devices, such as Raspberry Pi, dependencies for OpenCV-Python installed on the device. Run the following command to install the dependencies.

`sudo apt-get install libopenjp2-7 libilmbase23 libopenexr-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libgtk-3-0 libwebp-dev`

- Raspberry Pi devices that run Raspberry Pi OS Bullseye must meet the following requirements:

    - NumPy 1.22.4 or later installed on the device. To upgrade NumPy on the device, run `pip3 install --upgrade numpy`.

    - The legacy camera stack enabled on the device. Raspberry Pi OS Bullseye includes a new camera stack that is enabled by default and isn't compatible, so you must enable the legacy camera stack. To enable the legacy camera stack, run the following command to open the Raspberry Pi configuration tool.
        1. `sudo raspi-config`
        2. Select Interface Options.
        3. Select Legacy camera to enable the legacy camera stack.
        4. Reboot the Raspberry Pi.


## Configuration

This component provides the following configuration parameters that you can customize when you deploy the component.

 - <b>accessControl</b>

    (Optional) The object that contains the authorization policy that allows the component to publish messages to the default notifications topic.

    Default:
   ```
   {
      "aws.greengrass.ipc.mqttproxy": {
         "aws.greengrass.DLRImageClassification:mqttproxy:1": {
            "policyDescription": "Allows access to publish via topic ml/dlr/image-classification.",
            "operations": [
               "aws.greengrass#PublishToIoTCore"
            ],
            "resources": [
               "ml/dlr/image-classification"
            ]
         }
      }
   }
   ```
 - <b>PublishResultsOnTopic</b>

    (Optional) The topic on which you want to publish the inference results. If you modify this value, then you must also modify the value of resources in the accessControl parameter to match your custom topic name.

    Default: `ml/dlr/image-classification`
 - <b>Accelerator</b>

    The accelerator that you want to use. Supported values are cpu and gpu.

    The sample models in the dependent model component support only CPU acceleration. 

    Default: `cpu`
 - <b>ImageDirectory</b>

    (Optional) The path of the folder on the device where inference components read images. You can modify this value to any location on your device to which you have read/write access.

    Default: `/greengrass/v2/packages/artifacts-unarchived/component-name/image_classification/sample_images/`

    Note: If you set the value of UseCamera to true, then this configuration parameter is ignored.
 - <b>ImageName</b>

    (Optional) The name of the image that the inference component uses as an input to a make prediction. The component looks for the image in the folder specified in ImageDirectory. By default, the component uses the sample image in the default image directory. This component supports the following image formats: jpeg, jpg, png, and npy.

    Default: `cat.jpeg`

    Note: If you set the value of `UseCamera` to true, then this configuration parameter is ignored.
 - <b>InferenceInterval</b>

    (Optional) The time in seconds between each prediction made by the inference code. The sample inference code runs indefinitely and repeats its predictions at the specified time interval. For example, you can change this to a shorter interval if you want to use images taken by a camera for real-time prediction.

    Default: `3600`
 - <b>ModelResourceKey</b>

    (Optional) The models that are used in the dependent model component. 

    Default:
      ```
      {
         "armv7l": "DLR-resnet50-armv7l-cpu-ImageClassification",
         "aarch64": "DLR-resnet50-aarch64-cpu-ImageClassification",
         "x86_64": "DLR-resnet50-x86_64-cpu-ImageClassification",
         "windows": "DLR-resnet50-win-cpu-ImageClassification"
      }
      ```
 - <b>UseCamera</b>

    (Optional) String value that defines whether to use images from a camera connected to the Greengrass core device. Supported values are true and false.

    When you set this value to true, the sample inference code accesses the camera on your device and runs inference locally on the captured image. The values of the ImageName and ImageDirectory parameters are ignored. Make sure that the user running this component has read/write access to the location where the camera stores captured images.

    Default: `false`