#!/bin/sh

# Create users with interactive prompts
# Assumes the group ID is always equal to user ID
# REMINDER: The script has to work on Alpine (busybox - Ash)

set -e

exit_error() {
  echo "Error - $1"
  exit 1
}

echo "Please enter the user details for the new account:"
read -p "User ID: " USER_ID
[[ -z $USER_ID ]] && exit_error "User ID cannot be empty."
read -p "User name: " USER_NAME
[[ -z $USER_NAME ]] && exit_error "User name cannot be empty."
echo ""
echo "The chroot has to be **one level below** the actual home directory"
read -p "User chroot directory: " USER_ROOT
[[ ! -d $USER_ROOT ]] && exit_error "$USER_ROOT doesn't exist on the container."

# Check that the directory doesn't belong to that user or group
# And isn't world writable, print a warning if it is.
DIR_UID=$(stat -c "%u" "$USER_ROOT")
DIR_GID=$(stat -c "%g" "$USER_ROOT")
PERMS_ALL=$(stat -c "%a" "$USER_ROOT" | tail -c 2)
if [[ $DIR_UID != 0 ]] || [[ $DIR_GID != 0 ]]; then
  echo "WARNING: the provided chroot doesn't belong to root."
  echo "OpenSSH might refuse connections to such a chroot."
  echo "both user and group owners have to be root."
  echo "If you change the permissions, DO NOT DO IT RECURSIVELY."
  read -p "Continue? [y/N]"
  [[ "$REPLY" != "y" ]] && exit 0
  echo ""
fi
[[ $PERMS_ALL -gt 5 ]] && exit_error "$USER_ROOT is world writable, can't use such a directory as chroot"

# TODO adduser doesn't allow duplicate UIDs.
# I need to run usermod afterwards in that case.

# Check if a group already exists with the ID = User ID
GR=$(getent group $USER_ID)
if [[ $? -gt 0 ]]; then
  # Create both group and user:
  addgroup --gid $USER_ID "$USER_NAME"
  adduser -h "$USER_ROOT" -H -u $USER_ID -G "$USER_NAME" "$USER_NAME"
else
  # The gid is already in use, get the name of the group and use that
  # to create the user:
  GR_NAME=$(echo "$GR" | cut -d: -f 1)
  adduser -h "$USER_ROOT" -H -u $USER_ID -G "$GR_NAME" "$USER_NAME"
fi

echo "User $USER_NAME has been created on the container."