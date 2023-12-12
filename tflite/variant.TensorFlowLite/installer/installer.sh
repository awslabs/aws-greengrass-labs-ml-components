#!/bin/bash
. $(dirname "$0")/utils.sh
. $(dirname "$0")/virtual_env.sh

set -eu

ml_root_path=""
environment_file=""
use_installer=""

# Get the parameters
while getopts ":p:e:i:" opt; do
    case $opt in
    p)
        ml_root_path="$OPTARG"
        ;;
    e)
        environment_file="$OPTARG"
        ;;
    i)
        use_installer="$OPTARG"
        ;;
    \?)
        echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done

if [ "$use_installer" = true ]; then
  echo "Running TensorFlow Lite install script...";
else
  echo "Skipping installation of component dependencies.";
  exit 0;
fi

# Validate the input params
if [[ -z "$ml_root_path" ]]; then
    echo "ML root path cannot be null or empty."
    exit 1
fi
ml_root_path=$(echo "$(cd "$(dirname "$ml_root_path")"; pwd)/$(basename "$ml_root_path")")

kernel=$(uname -s)
tf_version="2.5.0"
tflite_version="2.5.0.post1"
tflite_fallback_version="2.5.0"
min_py_version="3.0.0"
min_kernel_version="4.9.9"
min_pip_version="20.2.4"
machine=$(uname -m)
python_version=$(echo $(python3 --version) | cut -d' ' -f 2)
pip3_version=$(echo $(pip3 --version) | cut -d' ' -f 2)
jetson_device_chip="/sys/module/tegra_fuse/parameters/tegra_chip_id"

# Supported tflite wheels for different devices based on the tflite version, python version and os version can be found at
# https://google-coral.github.io/py-repo/
tf_lite_link="https://google-coral.github.io/py-repo/tflite-runtime/"


if [ -f "$jetson_device_chip" ]; then
    # We need to export this flag otherwise the check for opencv being installed might fail because of
    # a reported issue between numpy version 1.19.5 and OpenBLAS (opencv depends on numpy).
    # https://github.com/numpy/numpy/issues/18131
    export OPENBLAS_CORETYPE=$(uname -m | tr [:lower:] [:upper:])
fi

case "$kernel" in
"Linux")
    target_platform_whl="$(echo $kernel | awk '{print tolower($0)}')_$machine"".whl"
    if check_tf "$machine"; then
        echo "Skipping TensorFlow Lite installation as it already exists."
    else
        if is_debian; then
            . $(dirname "$0")/debian_installer.sh
            sudo apt install wget -y
            if [[ "$machine" == "x86_64" ]]; then
                echo "Installing Miniconda and creating virtual environment..."
                install_conda_x86_64 "$environment_file"
                echo "Installing system libraries"
                sudo apt-get install libgl1 -y
                echo "Installing awsiotsdk..."
                pip3 install awsiotsdk
            elif [[ "$machine" == "armv7l" ]]; then
                install_libraries_debian "$machine"
            elif [[ "$machine" == "aarch64" ]]; then
                install_libraries_debian "$machine"
            fi
        elif is_centos; then
            . $(dirname "$0")/centos_installer.sh
            sudo yum install wget -y
            if [[ "$machine" == "x86_64" ]]; then
                echo "Installing Miniconda and creating virtual environment..."
                install_conda_x86_64 "$environment_file"
                install_libraries_centos
                pip3 install awsiotsdk
            else
                install_py3_centos
                install_libraries_centos
                pip3 install awsiotsdk
            fi
        fi
        install_tflite
    fi
    ;;
"Darwin")
    . $(dirname "$0")/darwin_installer.sh
    install_libraries_darwin
    if check_tf "$machine"; then
        echo "Skipping TensorFlow Lite installation as it already exists."
    else
        echo "Installing Miniconda and creating virtual environment..."
        install_conda_darwin "$environment_file"
        install_tflite
    fi
    ;;
"Windows")
    . $(dirname "$0")/windows_installer.sh
    echo "Install like Windows..."
    echo "Curling the python.exe file"
    echo "Installing python without UI command. Also include pip"
    echo "Use it to install pip libraries."
    echo "OR"
    echo "install miniconda on windows"
    ;;
esac