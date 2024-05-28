FROM linux-base
# FROM 268845366347.dkr.ecr.us-east-1.amazonaws.com/base/linux-base:latest

USER root
WORKDIR /opt

## ============================ WIRESHARK ============================
# Install Wireshark
# this bypasses the interactive element needed in the install process
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections \
    && sudo add-apt-repository ppa:wireshark-dev/stable -y \
    && sudo apt update \
    && sudo apt install -y wireshark

# Add coder to the group to be able to run wireshark
RUN sudo usermod -a -G wireshark $USER \
    && sudo setcap cap_net_admin,cap_net_raw=ep /usr/bin/dumpcap

## ============================ VSCODE ==========================
# Install 
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y code \
    && rm -f microsoft.gpg

## ============================ CHROMIUM =======================
# Get debian repos for chromium
COPY debian.list /etc/apt/sources.list.d/debian.list
RUN sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys DCC9EFBF77E11517 \
    && sudo gpg --export 77E11517 | sudo gpg --dearmour -o /usr/share/keyrings/debian-buster.gpg 
RUN sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 648ACFD622F3D138 \
    && sudo gpg --export 22F3D138 | sudo gpg --dearmour -o /usr/share/keyrings/debian-buster-updates.gpg 
RUN sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 112695A0E562B32A \
    && sudo gpg --export E562B32A | sudo gpg --dearmour -o /usr/share/keyrings/debian-security-buster.gpg
COPY chromium.pref /etc/apt/preferences.d/chromium.pref

# Install chromium from debian repo
RUN sudo apt update \
    && sudo apt install -y chromium

# Allow for easier customization of filesystem, especially under mount point
COPY coursera-start.sh /dockerstartup/coursera-start.sh

# Run chmod separately from COPY because Coursera docker does not support it
RUN sudo chmod 777 /dockerstartup/coursera-start.sh

# Explicitly start window manager
# xfce4-session initializes the entire linux desktop session, so we want to 
# explicitly add in a call to start the window manager just before it to make
# sure a window manager is running.
# RUN sudo sed -i 's/^\s*xfce4-session/    xfwm4\n    xfce4-session/g' /etc/xdg/xfce4/xinitrc

## ============================ CORE/EMANE =======================
USER root

ARG PREFIX=/usr/local
ARG BRANCH=master
ARG PROTOC_VERSION=3.19.6
ARG VENV_PATH=/opt/core/venv
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$PATH:${VENV_PATH}/bin"
WORKDIR /opt

# install system dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    sudo \
    wget \
    tzdata \
    libpcap-dev \
    libpcre3-dev \
    libprotobuf-dev \
    libxml2-dev \
    protobuf-compiler \
    unzip \
    uuid-dev \
    iproute2 \
    iputils-ping \
    tcpdump && \
    apt-get autoremove -y

# install core
RUN git clone https://github.com/coreemu/core && \
    cd core && \
    git checkout ${BRANCH} && \
    ./setup.sh
RUN cd core && PATH=/home/coder/.local/bin:$PATH inv install -v -p ${PREFIX}
    # cd /opt && rm -rf ospf-mdr

# install emane
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    mkdir protoc && \
    unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d protoc && \
    git clone https://github.com/adjacentlink/emane.git && \
    cd emane && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make -j$(nproc)  && \
    make install && \
    cd src/python && \
    make clean && \
    PATH=/opt/protoc/bin:$PATH make && \
    ${VENV_PATH}/bin/python -m pip install . && \
    cd /opt && \
    rm -rf protoc && \
    rm -rf emane && \
    rm -f protoc-${PROTOC_VERSION}-linux-x86_64.zip

## ============================ SCHC Docker Lab =======================
WORKDIR ${HOME}

# install utils and openschc requirements
RUN apt-get install -y x11-xserver-utils nano vim mousepad
RUN pip install scapy cbor2 netifaces
# setup CORE scenario and terminal configs
COPY ./configs/schc-ping.xml ${HOME}/.coregui/xmls/schc-ping.xml
COPY ./configs/bash-config ${HOME}/bash-config
RUN cat ${HOME}/bash-config >> /root/.bashrc && rm ${HOME}/bash-config
RUN echo 'alias sudop="sudo env PATH=$PATH"' >> ${HOME}/.bashrc
RUN sudo chown -R ${USER}:${USER} ${HOME}/.coregui

#################################
### VNC ####
#################################

WORKDIR ${HOME}
USER ${USER}

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]

# For local M1+ Mac testing
# RUN mkdir -p ~/.config/Code/User/ && echo '{"extensions.verifySignature": false}' > ~/.config/Code/User/settings.json

# Create desktop icons
COPY --chown=${USER}:${USER} desktop-apps/ ${HOME}/Desktop/
RUN chmod 755 ${HOME}/Desktop/Chromium.desktop ${HOME}/Desktop/VSCode.desktop ${HOME}/Desktop/Wireshark.desktop ${HOME}/Desktop/CORE.desktop 

