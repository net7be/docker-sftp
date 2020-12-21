# SFTP Docker image files

From the project root, building the image:
```
docker build -t <IMAGE_TAG> .
```

Then to start a new container in the background based on the image:
```
docker run -d --name <CONTAINER_NAME> -p 2222:22 -v <SFTP_DIRECTORY_ROOT>:<SFTP_DIRECTORY_ROOT> <IMAGE_TAG>
```

You can now start and stop it manually: 
```
docker start <CONTAINER_NAME>
docker stop <CONTAINER_NAME>
```

# Adding user accounts
We're just adding regular system accounts and specifying their home directory to be inside the mounted SFTP_DIRECTORY_ROOT.

You have to handle the permissions yourselves by matching the UID/GUID from the container with the acutal ones from the hosts and the mounted directory.

# Making it run when system boots up
Adding `--restart=always` to the `docker run` command should do it.

# How to add/change mount points
To do this without resetting SSH keys and having to recreate the accounts, I'm pretty sure you have to commit the old container as a new image, and run a new container based on that image.