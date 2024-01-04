## Greengrass components for performing Machine learning inference on a core device.

This repository consists of sample components for performing ML inference such as image classification and object detection using Deep Learning Runtime and TensorFlow Lite machine learning runtimes. 

The provided sample components are categorized into the following:
- Model component—Contains machine learning models as Greengrass artifacts.

- Runtime component—Contains the script that installs the machine learning framework and its dependencies on the Greengrass core device.

- Inference component—Contains the inference code and includes component dependencies to install the machine learning framework and download pre-trained machine learning models.

## Machine learning Components 

DLR Runtime

| Component name      | Description |
| :---        |    :----:   |
| [variant.DLR](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/dlr/variant.DLR)    | Runtime component that contains an installation script that is used to install DLR and its dependencies on the Greengrass core device.       |
| [aws.greengrass.DLRObjectDetection](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/dlr/aws.greengrass.DLRObjectDetection)    | Inference component that uses the DLR object detection model store and the DLR runtime component as dependencies to install DLR, download sample object detection models, and perform object detection inference on supported devices.       |
| [aws.greengrass.DLRImageClassification](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/dlr/aws.greengrass.DLRImageClassification)    | Inference component that uses the DLR image classification model store and the DLR runtime component as dependencies to install DLR, download sample image classification models, and perform image classification inference on supported devices.       |
| [variant.DLR.ImageClassification.ModelStore](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/dlr/variant.DLR.ImageClassification.ModelStore)      | Model component that contains sample ResNet-50 image classification models as Greengrass artifacts.       |
| [variant.DLR.ObjectDetection.ModelStore](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/dlr/variant.DLR.ObjectDetection.ModelStore)   | Model component that contains sample YOLOv3 object detection models as Greengrass artifacts.        |

TensorFlow Lite

| Component name      | Description |
| :---        |    :----:   |
| [variant.TensorFlowLite](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/tflite/variant.TensorFlowLite)         | Runtime component that contains an installation script that is used to install TensorFlow Lite and its dependencies on the Greengrass core device.       |
| [aws.greengrass.TensorFlowLiteImageClassification](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/tflite/aws.greengrass.TensorFlowLiteImageClassification)   | Inference component that uses the TensorFlow Lite image classification model store and the TensorFlow Lite runtime component as dependencies to install TensorFlow Lite, download sample image classification models, and perform image classification inference on supported devices.        |
| [aws.greengrass.TensorFlowliteObjectDetection](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/tflite/aws.greengrass.TensorFlowliteObjectDetection)      | Inference component that uses the TensorFlow Lite object detection model store and the TensorFlow Lite runtime component as dependencies to install TensorFlow Lite, download sample object detection models, and perform object detection inference on supported devices.       |
| [variant.TensorFlowLite.ImageClassification.ModelStore](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/tflite/variant.TensorFlowLite.ImageClassification.ModelStore)         | Model component that contains a sample MobileNet v1 model as a Greengrass artifact.       |
| [variant.TensorFlowLite.ObjectDetection.ModelStore](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/tflite/variant.TensorFlowLite.ImageClassification.ModelStore)         | Model component that contains a sample Single Shot Detection (SSD) MobileNet model as a Greengrass artifact.       |

## Build and publish components using GDK

To create a component in your AWS account, navigate to that component folder and run the GDK commands for building and publishing the component. 

For eg, to create a new component version of <b>variant.TensorFlowLite</b> in your AWS account, navigate to [variant.TensorFlowLite](https://github.com/awslabs/aws-greengrass-labs-ml-components/tree/main/tflite/variant.TensorFlowLite) folder and update the `gdk-config.json` as per your requirement. 

- Now, to build the component, run the following command. 

`gdk component build`

- Once the component is successfully built, provide your aws credentials in the terminal and run the following command to create the component version in your account.

`gdk component publish`

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the Apache-2.0 License.

