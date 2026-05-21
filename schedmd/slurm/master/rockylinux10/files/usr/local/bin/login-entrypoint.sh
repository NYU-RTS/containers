#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to daemons.
export SSHD_OPTIONS="${SSHD_OPTIONS:-""}"
export SACKD_OPTIONS="${SACKD_OPTIONS:-""}"
export SSSD_OPTIONS="${SSSD_OPTIONS:-""}"

function entrypointd() {
	if [ -d /usr/local/entrypoint.d/ ]; then
		echo "[entrypoint.d] Files: $(ls -laF /usr/local/entrypoint.d/)"
	fi
	for file in /usr/local/entrypoint.d/*; do
		if [ -f "$file" ] && [ -x "$file" ]; then
			echo "[entrypoint.d] Run: $file"
			"$file"
		fi
	done
}

function main() {
	mkdir -p /run/sshd/
	chmod 0755 /run/sshd/
	mkdir -p /run/dbus/
	rm -f /var/run/dbus/pid

	ssh-keygen -A

	entrypointd

	exec supervisord -c /etc/supervisord.conf
}
main
