#!/bin/bash

# This script should be owned by root:root, so that it can't be modified, 
# tricking you in to executing commands with elevated credentials.

apt update && apt full-upgrade && apt autoremove --purge
