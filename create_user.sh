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
if [[ $DIR_UID -eq $USER_ID ]] || [[ $DIR_GID -eq $USER_ID ]]; then
  echo "WARNING: the provided chroot belongs to the provided user ID or group ID"
  echo "OpenSSH might refuse connections to such a chroot."
  read -p "Continue? [y/N]"
  [[ "$REPLY" != "y" ]] && exit 0
  echo ""
fi
[[ $PERMS_ALL -gt 5 ]] && exit_error "$USER_ROOT is world writable, can't use such a directory as chroot"

set +e
addgroup --gid $USER_ID "$USER_NAME"
set -e
adduser -h "$USER_ROOT" -H -u $USER_ID -G "$USER_NAME" "$USER_NAME"

echo "User $USER_NAME has been created on the container."