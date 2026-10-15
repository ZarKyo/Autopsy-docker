#!/bin/sh
# Optional SSH mode: run Autopsy through `ssh -X` from a remote or non-Linux client (MobaXterm, etc.).
# Must run as root (sshd). The password comes from SSH_PASSWORD at runtime; nothing is baked into the image.
set -eu

if [ -z "${SSH_PASSWORD:-}" ]; then
    echo "SSH_PASSWORD must be set to use SSH mode" >&2
    exit 1
fi

echo "autopsy:${SSH_PASSWORD}" | chpasswd
usermod -s /bin/bash autopsy

# SSH sessions do not inherit the container environment: expose the Java rendering options through pam_env
touch /etc/environment
sed -i '/^JAVA_TOOL_OPTIONS=/d' /etc/environment
if [ -n "${JAVA_TOOL_OPTIONS:-}" ]; then
    echo "JAVA_TOOL_OPTIONS=\"${JAVA_TOOL_OPTIONS}\"" >> /etc/environment
fi

# Host keys are generated per container, not shipped in the image
ssh-keygen -A
mkdir -p /run/sshd

exec /usr/sbin/sshd -D -e
