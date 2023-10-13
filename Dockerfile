FROM ubuntu:20.04

ARG SLEUTHKIT_VERSION=4.12.1-1
ARG AUTOPSY_VERSION=4.21.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y tzdata testdisk wget gnupg sudo

WORKDIR /tmp

RUN wget https://raw.githubusercontent.com/sleuthkit/autopsy/develop/linux_macos_install_scripts/install_prereqs_ubuntu.sh
RUN chmod +x install_prereqs_ubuntu.sh
RUN ./install_prereqs_ubuntu.sh
RUN wget https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-4.12.1/sleuthkit-java_${SLEUTHKIT_VERSION}_amd64.deb
RUN wget https://github.com/sleuthkit/autopsy/releases/download/autopsy-${AUTOPSY_VERSION}/autopsy-${AUTOPSY_VERSION}.zip
RUN apt update && apt install -y ./sleuthkit-java_${SLEUTHKIT_VERSION}_amd64.deb
RUN wget https://raw.githubusercontent.com/sleuthkit/autopsy/develop/linux_macos_install_scripts/install_application.sh
RUN chmod +x install_application.sh
RUN ./install_application.sh -z /tmp/autopsy-${AUTOPSY_VERSION}.zip -i /opt/autopsy -j /usr/lib/jvm/java-1.17.0-openjdk-amd64

RUN rm /tmp/autopsy-${AUTOPSY_VERSION}.zip install_application.sh install_prereqs_ubuntu.sh sleuthkit-java_${SLEUTHKIT_VERSION}_amd64.deb 

RUN ln -s /opt/autopsy/autopsy-${AUTOPSY_VERSION}/bin/autopsy /bin/
CMD ["/bin/autopsy", "--nosplash"]
