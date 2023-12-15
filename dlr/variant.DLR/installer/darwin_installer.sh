install_libraries_darwin() {
    install_brew_darwin
    install_cmake_darwin
    install_gcc_darwin
}
install_cmake_darwin() {
    if [ -z "$(cmake --version)" ]; then
        echo "Installing cmake..."
        brew install cmake
    fi
}
install_gcc_darwin() {
    if [ -z "$(gcc --version)" ]; then
        echo "Installing gcc@8..."
        brew install gcc@8
    fi
}
install_brew_darwin() {
    if [ -z "$(brew --version)" ]; then
        echo "Installing brew..."
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
        export PATH="/usr/local/opt/python/libexec/bin:$PATH"
    fi
}
