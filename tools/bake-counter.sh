#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Bake a visitor count into index.html.
#
# To be plain about it in the one place a future maintainer will look: the
# number is invented. It is not analytics and it is not derived from anything
# that happened. There is no pixel, no third party and no script in the
# visitor's browser, because a real count needs at least one of those and the
# badge two lines above it in the footer says NO JS.
#
# What it does instead is what every counter on a 1997 homepage was doing under
# the hood anyway: show a number that goes up. It is decoration in the same
# spirit as "best viewed at 1280x960".
#
# Deterministic on purpose. Twice on the same day produces the same number, so
# a re-run or a re-deploy never makes the count jump or, worse, go backwards.
# The daily drift is larger than the jitter, which is what keeps it monotonic.
#
# Environment:
#   PAGE       file to rewrite, default index.html
#   FAKE_DATE  override today, for testing (YYYY-MM-DD)

set -euo pipefail

PAGE="${PAGE:-index.html}"
START="2026-08-30"   # the day the site went up
BASE=1024            # where the counter started
PER_DAY=9            # average drift per day

today="${FAKE_DATE:-$(date -u +%F)}"
days=$(( ( $(date -u -d "${today}" +%s) - $(date -u -d "${START}" +%s) ) / 86400 ))
[ "${days}" -lt 0 ] && days=0

# A stable per-day wobble in 0..8, so the count does not climb by exactly nine
# every single day. Strictly less than PER_DAY, so tomorrow is always larger
# than today however the two wobbles land.
jitter=$(( 0x$(printf '%s' "${today}" | sha256sum | cut -c1-8) % PER_DAY ))

count=$(( BASE + days * PER_DAY + jitter ))
printf -v padded '%07d' "${count}"

if ! grep -q '<!--HITS-->' "${PAGE}"; then
  echo "bake-counter: no <!--HITS--> markers in ${PAGE}, nothing to do." >&2
  exit 0
fi

tmp="$(mktemp)"
sed -E "s|<!--HITS-->[^<]*<!--/HITS-->|<!--HITS-->${padded}<!--/HITS-->|" "${PAGE}" > "${tmp}"
mv "${tmp}" "${PAGE}"
echo "bake-counter: ${padded} (day ${days})"
