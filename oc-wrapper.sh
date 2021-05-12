#!/bin/bash

APP_ROOT=${APP_ROOT:-/opt/app-root}

case $OC_VERSION in
    4.*)
        OC_VERSION=4
        ;;
    *)
        OC_VERSION=3.11
        ;;
esac

exec ${APP_ROOT}/bin/oc-$OC_VERSION "$@"
