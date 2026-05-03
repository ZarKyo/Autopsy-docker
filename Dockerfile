FROM ubuntu:24.04

ARG SLEUTHKIT_VERSION=4.15.0
ARG AUTOPSY_VERSION=4.23.0

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Bootstrap tools needed before the Autopsy prereqs script runs
RUN apt-get update && \
    apt-get install -y tzdata testdisk wget gnupg lsof sudo

WORKDIR /tmp

# Install Autopsy's declared prerequisites (JDK 17, GStreamer, forensics libs, build tools…)
# Pinned to the matching Autopsy release tag so deps stay in sync with the version being installed
RUN wget https://raw.githubusercontent.com/sleuthkit/autopsy/autopsy-${AUTOPSY_VERSION}/linux_macos_install_scripts/install_prereqs_ubuntu.sh
RUN chmod +x install_prereqs_ubuntu.sh
RUN ./install_prereqs_ubuntu.sh

# Build SleuthKit from source: no .deb is published for 4.15.0, only a source tarball.
# The script clones the tagged release with --depth 1, then runs bootstrap + configure --enable-java + make install.
# ldconfig registers the newly installed native libs so the JNI layer can find them at runtime.
RUN wget https://raw.githubusercontent.com/sleuthkit/autopsy/autopsy-${AUTOPSY_VERSION}/linux_macos_install_scripts/install_tsk_from_src.sh && \
    chmod +x install_tsk_from_src.sh && \
    JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64 \
    ./install_tsk_from_src.sh -p /tmp/sleuthkit -b sleuthkit-${SLEUTHKIT_VERSION} && \
    ldconfig && \
    rm -rf /tmp/sleuthkit install_tsk_from_src.sh

# Download the Autopsy release zip and the official install script (pinned to the same tag)
RUN wget https://github.com/sleuthkit/autopsy/releases/download/autopsy-${AUTOPSY_VERSION}/autopsy-${AUTOPSY_VERSION}.zip
RUN wget https://raw.githubusercontent.com/sleuthkit/autopsy/autopsy-${AUTOPSY_VERSION}/linux_macos_install_scripts/install_application.sh
RUN chmod +x install_application.sh

# Extract and configure Autopsy under /opt/autopsy (runs the bundled unix_setup.sh internally)
RUN ./install_application.sh -z /tmp/autopsy-${AUTOPSY_VERSION}.zip -i /opt/autopsy -j /usr/lib/jvm/java-1.17.0-openjdk-amd64

# Clean up build artifacts and installer scripts
RUN rm /tmp/autopsy-${AUTOPSY_VERSION}.zip install_application.sh install_prereqs_ubuntu.sh

# Expose the autopsy binary globally
RUN ln -s /opt/autopsy/autopsy-${AUTOPSY_VERSION}/bin/autopsy /bin/

# Ubuntu 24.04 ships a default 'ubuntu' user at UID 1000; rename it to 'app' rather than
# creating a duplicate UID (useradd -u 1000 fails with "UID is not unique" on this base image)
RUN usermod -l app -d /home/app -m -s /sbin/nologin ubuntu
RUN chown -R 1000 /opt/autopsy
USER app

CMD ["/bin/autopsy", "--nosplash"]
