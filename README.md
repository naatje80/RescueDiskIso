# Rescue Disk Iso
Create free PartedMagic alternative based on systemrescuedisk.

## Preperation
1. Install distrobox
2. Create a new container based on arch linux: `distrobox create --root --name RescueDiskIsoBuild --image archlinux:latest`
3. Clone this repository

## Create iso
3. Enter the container: `distrobox enter --root RescueDiskIsoBuild`
4. Navigate to the repo.
5. Generate the iso: `./create_iso.sh`
6. To ensure a proper new build, remove the following old directories first: `sudo rm -rf systemrescue-sources/work systemrescue-sources/out`
