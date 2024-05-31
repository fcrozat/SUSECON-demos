#!/bin/bash

run_checks() {
    systemctl is-failed -q mariadb
    test $? -ne 1 && exit 1
}

stop_services() {
    systemctl stop mariadb
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
