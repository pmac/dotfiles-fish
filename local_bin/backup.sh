#!/usr/bin/bash

sudo dnf history userinstalled | cat > ~/userinstalled.txt

export RESTIC_REPOSITORY='sftp:dan@192.168.1.4:restic-dan-neutraface'

restic backup --one-file-system --exclude-caches --exclude-file ~/.restic-exclude ~
