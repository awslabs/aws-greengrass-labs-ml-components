##############  debian  ####################
# Check if python3 already exists on the machine. Otherwise, install it.
install_py3_debian() {
    if [[ "$(version $python_version)" -ge "$(version $min_py_version)" ]] && [[ "$python_version" != *"command not found"* ]]; then
        echo "Skipping python3 installation as it is already installed"
    else
        echo "Installing python3..."
        sudo apt-get install -y python3 python3-distutils
    fi
    install_pip3_debian
}
# Check if pip3 already exists on the machine. Otherwise, install it.
install_pip3_debian() {
    if [[ "$(version $pip3_version)" -ge "$(version $min_pip_version)" ]] && [[ "$pip3_version" != *"command not found"* ]]; then
        echo "Skipping pip3 installation as it is already installed"
    else
        echo "Installing pip3..."
        sudo apt-get install -y python3-pip
        pip3 install -U pip setuptools wheel
    fi
}
# Install python3, pip3, setuptools, utils and wheel packages for debian on architectures other than x86_64 inside a venv.
# Install libraries needed for building from source such as git, cmake and build-essential.
install_libraries_debian() {
    install_py3_debian
    sudo apt install libatlas-base-dev python3-venv -y
    echo "Setting up Python virtual environment..."
    setup_venv "${1}"
    install_python3_libraries
}
