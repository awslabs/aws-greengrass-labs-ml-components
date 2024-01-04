# TensorFlow Lite runtime

The TensorFlow Lite runtime component (variant.TensorFlowLite) contains a script that installs TensorFlow Lite version 2.5.0 and its dependencies in a virtual environment on your device. The TensorFlow Lite image classification and TensorFlow Lite object detection component use this runtime component as a dependency for installing TensorFlow Lite. 

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

- <b>MLRootPath</b>

    (Optional) The path of the folder on Linux core devices where inference components read images and write inference results. You can modify this value to any location on your device to which the user running this component has read/write access.

    Default: `/greengrass/v2/work/variant.TensorFlowLite/greengrass_ml`
- <b>WindowsMLRootPath</b>

    (Optional) The path of the folder on Windows core device where inference components read images and write inference results. You can modify this value to any location on your device to which the user running this component has read/write access.

    Default: `C:\greengrass\v2\work\variant.TensorFlowLite\greengrass_ml`
- <b>UseInstaller</b>

    (Optional) String value that defines whether to use the installer script in this component to install DLR and its dependencies. Supported values are true and false.

    Set this value to false if you want to use a custom script for DLR installation, or if you want to include runtime dependencies in a pre-built Linux image. To use this component with the AWS-provided DLR inference components, install the following libraries, including any dependencies, and make them available to the system user, such as ggc_user, that runs the ML components.

        - Python 3.7 or later, including pip for your version of Python.
        - TensorFlow Lite v2.5.0
        - NumPy
        - OpenCV-Python
        - AWS IoT Device SDK v2 for Python
        - AWS Common Runtime (CRT) Python
        - Picamera (for Raspberry Pi devices only).
        awscam module (for AWS DeepLens devices).

        - libGL (for Linux devices)

    Default: `true`