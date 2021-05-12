#!/bin/bash

set -x

set -eo pipefail

APP_ROOT=/opt/app-root

JUPYTER_ENABLE_LAB=true
export JUPYTER_ENABLE_LAB

exec ${APP_ROOT}/bin/start-notebook.sh "$@"
