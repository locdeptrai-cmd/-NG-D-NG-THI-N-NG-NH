#!/usr/bin/env bash
# Root shim for Render startCommand/initialDeployHook.
set -o errexit
cd "$(dirname "$0")/../online"
exec bash scripts/render_initial_data.sh
