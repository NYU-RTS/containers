#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Additional arguments to pass to slurmctld.
export SLURMCTLD_OPTIONS="${SLURMCTLD_OPTIONS:-} $*"

# Additional arguments to pass to daemons.
export SSSD_OPTIONS="${SSSD_OPTIONS:-}"

function main() {
	mkdir -p /run/slurmctld/
	# sssd's own postinst creates /run/sssd/ at image build time, but /run
	# is ephemeral per FHS and nothing guarantees that survives into the
	# running container -- same reason slurmd/login's entrypoints
	# pre-create /run/sshd/ before starting sshd. Without this, sssd fails
	# to write its pidfile and gets stuck in a FATAL restart loop.
	mkdir -p /run/sssd/

	exec supervisord -c /etc/supervisor/supervisord.conf
}
main
