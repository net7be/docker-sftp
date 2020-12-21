#!/bin/sh

# Regenerate SSH host keys if this is the first time
# the container is started:
INIT_FILE=/initialized
if [ ! -f "$INIT_FILE" ]; then
  echo "Generating SSH host keys..."
  ssh-keygen -A
  echo "1" > $INIT_FILE
fi

# Start the OpenSSH server:
/usr/sbin/sshd -D -e