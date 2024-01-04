
# DLR object detection model store

The DLR object detection model store is a machine learning model component that contains pre-trained YOLOv3 models as Greengrass artifacts. The sample models used in this component are fetched from the GluonCV Model Zoo and compiled using SageMaker Neo Deep Learning Runtime. The DLR object detection inference component uses this component as a dependency for the model source. 