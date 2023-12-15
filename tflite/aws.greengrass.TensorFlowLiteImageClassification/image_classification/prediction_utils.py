import ast
import datetime
import io
import json
import os
import platform
import sys
import time

import config_utils
import cv2
import IPCUtils as ipc_utils
import numpy as np
import tflite_runtime.interpreter as tflite

config_utils.logger.info("Using tflite from '{}'.".format(sys.modules[tflite.__package__].__file__))
config_utils.logger.info("Using np from '{}'.".format(np.__file__))
config_utils.logger.info("Using cv2 from '{}'.".format(cv2.__file__))

# Read labels file
labels_path = os.path.join(config_utils.MODEL_DIR, "labels.txt")
with open(labels_path, "r") as f:
    labels = ast.literal_eval(f.read())
try:
    interpreter = tflite.Interpreter(
        model_path=os.path.join(config_utils.MODEL_DIR, "model.tflite")
    )
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
except Exception as e:
    config_utils.logger.info("Exception occured during the allocation of tensors: {}".format(e))
    exit(1)


def predict_from_cam():
    r"""
    Captures an image using camera and sends it for prediction
    """
    cvimage = None
    if config_utils.CAMERA is None:
        config_utils.logger.error("Unable to support camera")
        exit(1)
    if platform.machine() == "armv7l":  # RaspBerry Pi
        stream = io.BytesIO()
        config_utils.CAMERA.start_preview()
        time.sleep(2)
        config_utils.CAMERA.capture(stream, format="jpeg")
        # Construct a numpy array from the stream
        data = np.fromstring(stream.getvalue(), dtype=np.uint8)
        # "Decode" the image from the array, preserving colour
        cvimage = cv2.imdecode(data, 1)
    elif platform.machine() == "aarch64":  # Nvidia Jetson TX
        if config_utils.CAMERA.isOpened():
            ret, cvimage = config_utils.CAMERA.read()
            cv2.destroyAllWindows()
        else:
            raise RuntimeError("Cannot open the camera")
    elif platform.machine() == "x86_64":  # Deeplens
        ret, cvimage = config_utils.CAMERA.getLastFrame()
        if ret == False:
            raise RuntimeError("Failed to get frame from the stream")
    if cvimage is not None:
        return predict_from_image(cvimage)
    else:
        config_utils.logger.error("Unable to capture an image using camera")
        exit(1)


def load_image(image_path):
    r"""
    Validates the image type irrespective of its case. For eg. both .PNG and .png are valid image types.
    Also, accepts numpy array images.

    :param image_path: path of the image on the device.
    :return: a numpy array of shape (1, input_shape_x, input_shape_y, no_of_channels)
    """
    # Case insenstive check of the image type.
    img_lower = image_path.lower()
    if (
        img_lower.endswith(
            ".jpg",
            -4,
        )
        or img_lower.endswith(
            ".png",
            -4,
        )
        or img_lower.endswith(
            ".jpeg",
            -5,
        )
    ):
        try:
            image_data = cv2.imread(image_path)
        except Exception as e:
            config_utils.logger.error(
                "Unable to read the image at: {}. Error: {}".format(image_path, e)
            )
            exit(1)
    elif img_lower.endswith(
        ".npy",
        -4,
    ):
        image_data = np.load(image_path)
    else:
        config_utils.logger.error("Images of format jpg,jpeg,png and npy are only supported.")
        exit(1)
    return image_data


def predict_from_image(image):
    r"""
    Resize the image to the trained model input shape and predict using it.

    :param image: numpy array of the image passed in for inference
    """
    cvimage = cv2.resize(image, config_utils.SHAPE)
    predict(cvimage)


def enable_camera():
    r"""
    Checks of the supported device types and access the camera accordingly.
    """
    if platform.machine() == "armv7l":  # RaspBerry Pi
        import picamera

        config_utils.CAMERA = picamera.PiCamera()
    elif platform.machine() == "aarch64":  # Nvidia Jetson Nano
        config_utils.CAMERA = cv2.VideoCapture(
            "nvarguscamerasrc ! video/x-raw(memory:NVMM),"
            + "width=(int)1920, height=(int)1080, format=(string)NV12,"
            + "framerate=(fraction)30/1 ! nvvidconv flip-method=2 !"
            + "video/x-raw, width=(int)1920, height=(int)1080,"
            + "format=(string)BGRx ! videoconvert ! appsink"
        )
    elif platform.machine() == "x86_64":  # Deeplens
        import awscam

        config_utils.CAMERA = awscam


def predict(image_data):
    r"""
    Performs image classification and predicts using the model.

    :param image_data: numpy array of the resized image passed in for inference.
    """
    PAYLOAD = {}
    PAYLOAD["timestamp"] = str(datetime.datetime.now())
    PAYLOAD["inference-type"] = "image-classification"
    PAYLOAD["inference-description"] = "Top {} predictions with score {} or above ".format(
        config_utils.MAX_NO_OF_RESULTS, config_utils.SCORE_THRESHOLD
    )
    PAYLOAD["inference-results"] = []
    try:
        image_data = np.expand_dims(image_data, axis=0).astype(np.uint8)
        interpreter.set_tensor(input_details[0]["index"], image_data)
        interpreter.invoke()
        model_output = interpreter.get_tensor(output_details[0]["index"])
        # Obtained scores range from 0 to 255 as quantized model is used in the sample.
        # Divide it with 255 to get probabilties that range from 0 to 1.
        probabilities = model_output[0] / config_utils.SCORE_CONVERTER
        sort_classes_by_probability = np.argsort(probabilities)[::-1]
        for i in sort_classes_by_probability[: config_utils.MAX_NO_OF_RESULTS]:
            if probabilities[i] >= config_utils.SCORE_THRESHOLD:
                result = {"Label": str(labels[i]), "Score": str(probabilities[i])}
                PAYLOAD["inference-results"].append(result)
        config_utils.logger.info(json.dumps(PAYLOAD))
        if config_utils.TOPIC != "":
            ipc_utils.IPCUtils().publish_results_to_cloud(PAYLOAD)
        else:
            config_utils.logger.info("No topic set to publish the inference results to the cloud.")
    except Exception as e:
        config_utils.logger.error("Exception occured during prediction: {}".format(e))
