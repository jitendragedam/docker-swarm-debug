# Scripts to debug docker services

## Introduction
This is simple shell script that helps to debug a selected docker service. The selection is enabled by using the [gum](https://github/charmbracelet/gum).
The script provides following options as of now,
- Check logs of the selected docker service
- Debug the selected docker service
- Get TCP dump of the selected docker container

## Setup
For the script to work, the [gum](https://github/charmbracelet/gum) should be installed.

To install gum please refer to [gum installation](https://github.com/charmbracelet/gum#installation) or execute the [setup.sh](.setup.sh) script on Debian/Ubuntu.

After gum is installed, one can use the [debug.sh](./debug.sh) to debug, check logs and to take tcp dump of docker services.

