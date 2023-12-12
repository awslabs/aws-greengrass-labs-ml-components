get_tf_version_command=$(
    cat <<END
try:
    import tensorflow as tf
    print(tf.__version__)
except Exception as e:
    print(e)
END
)
get_opencv_version_command=$(
    cat <<END
try:
    import cv2
    print(cv2.__version__)
except Exception as e:
    print(e)
END
)
get_numpy_version_command=$(
    cat <<END
try:
    import numpy as np
    print(np.__version__)
except Exception as e:
    print(e)
END
)
get_awsiotsdk_command=$(
    cat <<END
try:
    import awsiot
except Exception as e:
    print(e)
END
)

version() {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
get_tf_compiled_py_version() {
    major="$(cut -d'.' -f 1 <<<$@)"
    minor="$(cut -d'.' -f 2 <<<$@)"
    echo "$major""$minor"
}

check_tf() {
    machine="${1}"
    if [[ "$machine" == "x86_64" ]]; then
        #Activate the conda environment before we check the TensorFlow installation (x86_64)
        if [ -f "${ml_root_path}/greengrass_ml_tflite_conda/bin/conda" ]; then
            #Activate conda
            export PATH="${ml_root_path}/greengrass_ml_tflite_conda/bin:$PATH"
            #See https://github.com/conda/conda/issues/7980 for an explanation of the below line
            eval "$(${ml_root_path}/greengrass_ml_tflite_conda/bin/conda shell.bash hook)"
            conda activate greengrass_ml_tflite_conda
        else
            return 1
        fi
    else
        #Activate the venv environment before we check the TensorFlow installation (other platforms)
        if [ -f "${ml_root_path}/greengrass_ml_tflite_venv/bin/activate" ]; then
            #Activate venv
            source ${ml_root_path}/greengrass_ml_tflite_venv/bin/activate
        else
            return 1
        fi
    fi
    get_tf_version=$(python3 -c "$get_tf_version_command")
    if [[ "$get_tf_version" == "$tf_version" ]]; then
        return 0
    else
        return 1
    fi
}

is_debian() {
    debian=$(sudo apt-get -v &>/dev/null && echo "apt-get")
    if [[ "$debian" == "apt-get" ]]; then
        return 0
    else
        return 1
    fi
}
is_centos() {
    centos_yum=$(type yum &>/dev/null && echo "yum")
    if [[ "$centos_yum" == "yum" ]]; then
        return 0
    else
        return 1
    fi
}

##############  Common  ####################
# Install python3 libraries.
install_python3_libraries() {
    # Check if opencv already exists on the machine. Otherwise, install it.
    opencv=$(python3 -c "$get_opencv_version_command")
    if [[ "$opencv" == *"No module named 'cv2'"* ]]; then
        echo "Installing opencv..."
        pip3 install opencv-python
    else
        echo "Skipping opencv installation as it already exists."
    fi
    # Check if numpy already exists on the machine. Otherwise, install it.
    numpy=$(python3 -c "$get_numpy_version_command")
    if [[ "$numpy" == *"No module named 'numpy'"* ]]; then
        echo "Installing numpy..."
        pip3 install numpy
    else
        echo "Skipping numpy installation as it already exists."
    fi
    # Check if awsiotsdk already exists on the machine. Otherwise, install it.
    awsiotsdk=$(python3 -c "$get_awsiotsdk_command")
    if [[ "$awsiotsdk" == *"No module named 'awsiot'"* ]]; then
        echo "Installing awsiotsdk..."
        pip3 install awsiotsdk
    else
        echo "Skipping awsiotsdk installation as it already exists."
    fi
}

install_tflite() {
    echo "Installing latest TensorFlowLite version..."
    pip3 install tflite-runtime

}