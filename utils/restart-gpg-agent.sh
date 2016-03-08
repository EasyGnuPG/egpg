#!/bin/bash

killall gpg-agent
rm -rf /tmp/gpg-*
echo "Start gpg-agent by reloading ~/.bashrc:"
echo "  source ~/.bashrc"
