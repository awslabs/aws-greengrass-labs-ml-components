#!/bin/bash
. $(dirname "$0")/utils.sh
. $(dirname "$0")/virtual_env.sh

set -eux

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
  echo "Running DLR install script...";
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
dlr_version="1.6.0"
min_py_version="3.0.0"
dlr_directory="neo-ai-dlr"
min_kernel_version="4.9.9"
min_pip_version="20.2.4"
machine=$(uname -m)
python_version=$(echo $(python3 --version) | cut -d' ' -f 2)
pip3_version=$(echo $(pip3 --version) | cut -d' ' -f 2)
jetson_device_chip="/sys/module/tegra_fuse/parameters/tegra_chip_id"
# Supported dlr pip wheels for different devices and dlr versions can be found at
# https://github.com/neo-ai/neo-ai-dlr/releases
dlr_link="https://neo-ai-dlr-release.s3-us-west-2.amazonaws.com/v"$dlr_version


if [ -f "$jetson_device_chip" ]; then
    # We need to export this flag otherwise the check for opencv being installed might fail because of
    # a reported issue between numpy version 1.19.5 and OpenBLAS (opencv depends on numpy).
    # https://github.com/numpy/numpy/issues/18131
    export OPENBLAS_CORETYPE=$(uname -m | tr [:lower:] [:upper:])
fi


case "$kernel" in
"Linux")
    if check_dlr "$machine"; then
        echo "Skipping DLR installation as it already exists."
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
                echo "Installing DLR..."
                pip3 install dlr=="$dlr_version"
                disable_metric_collection
            elif [[ "$machine" == "armv7l" ]]; then
                install_libraries_debian "$machine"
                os_version=$(echo $(egrep '^(VERSION_CODENAME)=' /etc/os-release) | cut -d'=' -f 2)

                # opencv2 requires libgtk-3-0 to be installed. Given we only saw this issue affect this machine
                # architecture and specifically the bullseye version of the Raspian OS we are only installing it
                # there to limit the potential impact that introducing a new package might have.
                if [[ "$os_version" == "bullseye" ]]
                 then
                  echo "Installing bullseye required packages..."
                  sudo apt-get update -y
                  sudo apt install libgtk-3-0 -y
                fi

                echo "Installing DLR..."
                pip3 install $dlr_link"/rasp3b/dlr-"$dlr_version"-py3-none-any.whl"
            elif [[ "$machine" == "aarch64" ]]; then
                install_libraries_debian "$machine"
                if [ -f "$jetson_device_chip" ]; then
                    echo "Installing DLR..."
                    pip3 install $dlr_link"/jetpack4.4/dlr-"$dlr_version"-py3-none-any.whl"
                else
                    echo "Installing DLR..."
                    pip3 install $dlr_link"/rasp4b/dlr-"$dlr_version"-py3-none-any.whl"
                fi
                disable_metric_collection
            else
                install_libraries_debian "$machine"
                echo "Could not install DLR using pip wheel. Installing DLR from source..."
                sudo apt-get install -y build-essential cmake ca-certificates git
                clone_repo
                cmake ..
                make_and_install
                disable_metric_collection
            fi
        elif is_centos; then
            . $(dirname "$0")/centos_installer.sh
            sudo yum install wget -y
            if [[ "$machine" == "x86_64" ]]; then
                echo "Installing Miniconda and creating virtual environment..."
                install_conda_x86_64 "$environment_file"
                install_libraries_centos
                echo "Installing DLR..."
                pip3 install dlr=="$dlr_version"
                disable_metric_collection
            else
                install_py3_centos
                install_libraries_centos
                echo "Could not install DLR using pip wheel. Installing DLR from source..."
                sudo yum install -y cmake3 ca-certificates git gcc-c++ gcc make
                clone_repo
                cmake3 ..
                make_and_install
                disable_metric_collection
            fi
        fi
    fi
    ;;
"Darwin")
    . $(dirname "$0")/darwin_installer.sh
    install_libraries_darwin
    if check_dlr "$machine"; then
        echo "Skipping DLR installation as it already exists."
    else
        echo "Installing Miniconda and creating virtual environment..."
        install_conda_darwin "$environment_file"
        echo "Installing DLR from source..."
        clone_repo
        CC=gcc-8 CXX=g++-8 cmake ..
        make_and_install
        disable_metric_collection
    fi
    ;;
"Windows")
    echo "Install like Windows..."
    ;;
esac
