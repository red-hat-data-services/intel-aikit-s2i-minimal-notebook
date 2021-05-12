#!/bin/bash

set -x

set -eo pipefail

APP_ROOT=/opt/app-root

if [ x"$JUPYTER_MASTER_FILES" != x"" ]; then
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_WORKSPACE_PATH=${APP_ROOT}/src/$JUPYTER_WORKSPACE_NAME
        setup-volume.sh $JUPYTER_MASTER_FILES $JUPYTER_WORKSPACE_PATH
    fi
fi

JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --config=${APP_ROOT}/etc/jupyter_kernel_gateway_config.py"

exec ${APP_ROOT}/bin/start.sh jupyter kernelgateway $JUPYTER_PROGRAM_ARGS "$@"
