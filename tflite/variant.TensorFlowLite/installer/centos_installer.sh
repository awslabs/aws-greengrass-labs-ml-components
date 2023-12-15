install_py3_centos() {
    if [[ "$(version $python_version)" -ge "$(version $min_py_version)" ]] && [[ "$python_version" != *"command not found"* ]]; then
        echo "Installing python3..."
        sudo yum install -y python37
    else
        echo "Skipping python3 installation as it already exists..."
    fi

    install_pip3_centos
}

# Check if pip3 already exists on the machine. Otherwise, install it.
install_pip3_centos() {
    if [[ "$(version $pip3_version)" -ge "$(version $min_pip_version)" ]] && [[ "$pip3_version" != *"command not found"* ]]; then
        echo "Installing pip3..."
        sudo yum install curl
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python3 get-pip.py
        rm get-pip.py
        validate_pip3_centos
        pip3 install -U setuptools wheel
    else
        pip3 install -U pip setuptools wheel
        validate_pip3_centos
    fi
}
validate_pip3_centos() {
    pip3_link="/usr/bin/pip3"
    if [ -e "$pip3_link" ]; then
        if [ -L "$pip3_link" ]; then
            echo "Symlink already exists."
        else
            echo "Removing the older pip3"
            sudo rm -rf "$pip3_link"
            sudo ln -s /usr/local/bin/pip3 "$pip3_link"
        fi
    else
        echo "Creating symlink..."
        sudo ln -s /usr/local/bin/pip3 "$pip3_link"
    fi
    pip3_version=$(echo $(pip3 --version) | cut -d' ' -f 2)
    if [[ "$pip3_version" == *"command not found"* || -z "$pip3_version" ]]; then
        echo "Error installing pip3"
        exit 1
    fi
    echo "pip3 is accessible by sudo"
}
install_libraries_centos() {
    install_python3_libraries
    sudo yum install mesa-libGL -y
}
