#!/bin/bash

set -x

set -eo pipefail

APP_ROOT=/opt/app-root

# The 'start-singleuser.sh' script is invoked by JupyterHub installations.
# Execute the 'run' script instead so everything goes through common
# entrypoint. That it is being run under JupyterHub will be determined
# later from environment variables set by JupyterHub.

exec ${APP_ROOT}/builder/run "$@"
