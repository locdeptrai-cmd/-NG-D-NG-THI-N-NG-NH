#!/usr/bin/env bash
# Root wrapper so Render dashboard buildCommand "./build.sh" still works
# after the Django app moved into online/.
set -o errexit
exec bash online/build.sh
