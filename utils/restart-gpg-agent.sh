#!/bin/bash

killall gpg-agent
rm -rf /tmp/gpg-*
rm -f $EGPG_DIR/.gpg-agent-info
unset GPG_AGENT_INFO
unset GPG_TTY
echo "Start gpg-agent by reloading ~/.bashrc:"
echo "  source ~/.bashrc"
