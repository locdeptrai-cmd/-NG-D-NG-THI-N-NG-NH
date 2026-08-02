#!/usr/bin/env bash
# Root shim for Render startCommand/initialDeployHook.
# Must not exec-replace the shell so "&& gunicorn ..." can continue.
set -o errexit
cd "$(dirname "$0")/../online"
bash scripts/render_initial_data.sh
