#!/bin/bash

set -x

set -eo pipefail

export $(cgroup-limits)

APP_ROOT=/opt/app-root

DASK_SCHEDULER_ADDRESS=${DASK_SCHEDULER_ADDRESS:-127.0.0.1:8786}

exec ${APP_ROOT}/bin/start.sh dask-worker $DASK_SCHEDULER_ADDRESS \
    --memory-limit $MEMORY_LIMIT_IN_BYTES $DASK_WORKER_ARGS "$@"
