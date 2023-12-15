#For x86_64, download and install miniconda and create a miniconda environment from a provided `environment.yaml`
#argument with all necessary dependencies required by TensorFlow
#This environment will be activated immediately after creation so that when TensorFlow is installed afterwards, it will only
#exist inside this environment
install_conda_x86_64() {
    #Check if we have already installed and set up conda on this device; if so, skip the installation
    if [ -f "${ml_root_path}/greengrass_ml_tflite_conda/bin/conda" ]; then
        return 0
    fi

    # Remove if partially created env exists
    rm -rf "${ml_root_path}/greengrass_ml_tflite_conda"

    environment_file="${1}"
    mkdir -p ${ml_root_path}
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O "${ml_root_path}/miniconda.sh"
    bash "${ml_root_path}/miniconda.sh" -b -p "${ml_root_path}/greengrass_ml_tflite_conda"
    rm "${ml_root_path}/miniconda.sh"

    export PATH="${ml_root_path}/greengrass_ml_tflite_conda/bin:$PATH"
    #See https://github.com/conda/conda/issues/7980 for an explanation of the below line
    eval "$(${ml_root_path}/greengrass_ml_tflite_conda/bin/conda shell.bash hook)"
    conda env create -f $environment_file
    conda activate greengrass_ml_tflite_conda

    #Uncomment to make `awscam` accessible inside conda for AWS Deeplens (use with caution)
    #sudo ln -s /usr/lib/python3/dist-packages/awscam "${ml_root_path}/greengrass_ml_tflite_conda/envs/greengrass_ml_tflite_conda/lib/python3.7/site-packages/"
    #sudo ln -s /usr/lib/python3/dist-packages/awscamdldt.so "${ml_root_path}/greengrass_ml_tflite_conda/envs/greengrass_ml_tflite_conda/lib/python3.7/site-packages/"
}

##Setup a venv for all python library installations on platforms with limited conda support
setup_venv() {
    machine="${1}"
    if [ ! -f "${ml_root_path}/greengrass_ml_tflite_venv/bin/activate" ]; then

        # Remove if partially created env exists
        rm -rf "${ml_root_path}/greengrass_ml_tflite_venv"

        #If the venv does not exist already, create it

        opencv_version_command_result=$(python3 -c "$get_opencv_version_command")
        if [[ "$opencv_version_command_result" == *"No module named 'cv2'"* ]]; then
          # Avoid using the --system-site-packages flag in systems where opencv has not been installed
          # since it may cause unintended side effects. Example: Raspbian GNU/Linux 11 (bullseye) comes by default
          # with python 3.9.2 and numpy 1.19.5. According to opencv-python 4.6.0.66 those requirements should work
          # but in reality they don't. We get a exception when importing cv2. We should let numpy
          # get installed on the virtual environment by opencv as its dependency and it would get the latest
          # version of the libraries that work with it instead of relying on the numpy preinstalled version.
          python3 -m venv ${ml_root_path}/greengrass_ml_tflite_venv
        else
          # Installation of python packages(eg.opencv) on some devices is super slow as it requires
          # compiling. To make use of the libraries that are already present on the device(eg. Certain
          # version of numpy, opencv are shipped with the jetpack sdk), we create the virtual env with access
          # to the modules that are present system wide.
          python3 -m venv ${ml_root_path}/greengrass_ml_tflite_venv --system-site-packages
        fi
    fi

    source ${ml_root_path}/greengrass_ml_tflite_venv/bin/activate
    cd ${ml_root_path}/greengrass_ml_tflite_venv

    #Uncomment to make `picamera` accessible inside venv for Raspberry pi (use with caution)
    #sudo ln -s /usr/lib/python3/dist-packages/picamera "${ml_root_path}/greengrass_ml_dlr_venv/lib/python3.7/site-packages"
}

install_conda_darwin() {
    #Check if we have already installed and set up conda on this device; if so, skip the installation
    if [ -f "${ml_root_path}/greengrass_ml_tflite_conda/bin/conda" ]; then
        return 0
    fi

    # Remove if partially created env exists
    rm -rf "${ml_root_path}/greengrass_ml_tflite_conda"

    environment_file="${1}"
    mkdir -p ${ml_root_path}
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh" -O "${ml_root_path}/miniconda.sh"
    bash "${ml_root_path}/miniconda.sh" -b -p "${ml_root_path}/greengrass_ml_tflite_conda"
    rm "${ml_root_path}/miniconda.sh"

    export PATH="${ml_root_path}/greengrass_ml_tflite_conda/bin:$PATH"
    #See https://github.com/conda/conda/issues/7980 for an explanation of the below line
    eval "$(${ml_root_path}/greengrass_ml_tflite_conda/bin/conda shell.bash hook)"
    conda env create -f $environment_file
    conda activate greengrass_ml_tflite_conda
}
