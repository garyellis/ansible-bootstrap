#!/bin/bash


ANSIBLE_VERSION=${ANSIBLE_VERSION:-latest}


install_initial_deps_yum(){
    echo yum -y --quiet install epel-release ca-certificates
    yum -y --quiet install epel-release ca-certificates
}

install_pip_centos(){
    pip_package_deps=(python-devel \
                      gcc \
                      PyYaml \
                      python-pip)

    echo yum -y --quiet install ${pip_package_deps[@]}
    yum -y --quiet install ${pip_package_deps[@]}
}

install_pip_ubuntu(){
    pip_package_deps=(python-dev \
                      python-pip)

    echo apt-get -qq update
    apt-get -qq update

    echo apt-get install -qq ${pip_package_deps[@]}
    apt-get install -qq ${pip_package_deps[@]}
}

install_pip_ansible_deps(){
    pip_ansible_deps=(pycrypto \
                      python-keyczar \
                      passlib \
                      boto)

    echo pip install ${pip_ansible_deps[@]}
    pip install ${pip_ansible_deps[@]}
}

install_ansible_module_deps_centos(){
    ansible_package_deps=(libselinux-python \
                          unzip \
                          findutils)

    yum -y --quiet install ${ansible_package_deps[@]}
}

install_ansible_module_deps_ubuntu(){
    ansible_package_deps=(unzip findutils)
    apt-get -qq install ${ansible_package_deps[@]}
}





# detect OS distro - configure dependencies installer functions
if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
    prep=install_initial_deps_yum
    pip_installer=install_pip_centos
    ansible_deps_installer=install_ansible_module_deps_centos
    # enabel epel repo

elif grep -iq ubuntu /etc/lsb-release || grep -iq ubuntu /etc/os-release ; then
    prep=
    pip_installer=install_pip_ubuntu
    ansible_deps_installer=install_ansible_module_deps_ubuntu

else
    echo "==> os not supported. failing"
    exit 1

fi

if [ "$1" == "uninstall" ]; then
    pip uninstall -y ansible

else
    if [ ! -z "$prep" ]; then
        eval $prep

    fi

    # install ansible module package dependencies
    eval $ansible_deps_installer

    # install pip
    eval $pip_installer
    install_pip_ansible_deps


    # finally install ansible
    if [ "$ANSIBLE_VERSION" == "latest" ]; then
        pip install ansible

    else
        pip install ansible==${ANSIBLE_VERSION}

    fi

fi
