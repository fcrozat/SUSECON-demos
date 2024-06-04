#!/bin/bash

run_checks() {
    podman system info > /dev/null 
    test $? -ne 0 && exit 1
}

stop_services() {
    exit 0
}

case "$1" in
    check)
	run_checks
	;;
    stop)
	stop_services
	;;
    *)
	echo "Usage: $0 {check|stop}"
	exit 1
	;;
esac

exit 0
