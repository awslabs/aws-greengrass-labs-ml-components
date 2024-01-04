
# DLR image classification model store

The DLR image classification model store is a machine learning model component that contains pre-trained ResNet-50 models as Greengrass artifacts. The pre-trained models used in this component are fetched from the GluonCV Model Zoo and are compiled using SageMaker Neo Deep Learning Runtime. The DLR image classification inference component uses this component as a dependency for the model source. 