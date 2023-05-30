# Install SGX related packages for SGX application development on servers.
# Based on Aliyun HK server ecs.g7t.large, and Ubuntu 20.04

# Error then exit immediately
set -e

# Constants
INSTALL_FOLDER=mysgx
INSTALLER_NAME=sgx_linux_x64_sdk_2.19.100.3.bin


# Error codes
NOT_ROOT=1
NO_SGX_KERNEL=2

# System information
USER_ID=$(id -u)
KERNEL_VERSION=$(uname -r)
SGX_NUMBER=$(ls -l /dev/ | grep sgx | wc -l)

if [ ${USER_ID} -ne 0 ]; then
    echo "Run this script as root! Abort"
    exit ${NOT_ROOT}
fi

echo 'Kernel version:' ${KERNEL_VERSION}
# Todo check kernel version to be > 5.11

if [ ${SGX_NUMBER} -eq 0 ]; then
    echo 'No kernel SGX driver support detected'
    exit ${NO_SGX_KERNEL}
fi

# Add trusted key entry
echo 'deb [signed-by=/etc/apt/keyrings/intel-sgx-keyring.asc arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu jammy main' | sudo tee /etc/apt/sources.list.d/intel-sgx.list

# Download the key
wget "https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key"

# Copy-paste key into correct location
cat intel-sgx-deb.key | sudo tee /etc/apt/keyrings/intel-sgx-keyring.asc > /dev/null

# Update
sudo apt-get update

# Essentials
sudo apt-get install build-essential python-is-python3

# SDK
sudo apt-get install -y libsgx-epid libsgx-quote-ex libsgx-dcap-ql

# Optional, debug tools.
sudo apt-get install -y libsgx-urts-dbgsym libsgx-enclave-common-dbgsym libsgx-dcap-ql-dbgsym libsgx-dcap-default-qpl-dbgsym

# Download developer tools
wget "https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu22.04-server/${INSTALLER_NAME}"

# Install it into the desire folder
chmod +x ${INSTALLER_NAME}
./${INSTALLER_NAME} --prefix ${INSTALL_FOLDER}

# Change the environment variable
source ${INSTALL_FOLDER}/sgxsdk/environment

# Install developer package
sudo apt-get install libsgx-enclave-common-dev libsgx-dcap-ql-dev libsgx-dcap-default-qpl-dev