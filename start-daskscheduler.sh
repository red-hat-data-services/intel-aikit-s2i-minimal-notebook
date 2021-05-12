#!/bin/bash

set -x

set -eo pipefail

APP_ROOT=/opt/app-root

exec ${APP_ROOT}/bin/start.sh dask-scheduler $DASK_SCHEDULER_ARGS "$@"
