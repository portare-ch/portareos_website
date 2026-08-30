#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Bake the visitor count into index.html.
#
# Counting is done by the no-JavaScript GoatCounter pixel in the page footer.
# This script reads the running total back out of GoatCounter's API and writes
# it between the <!--HITS--> markers, so the number in the page is a plain
# static string. Nothing runs in the visitor's browser.
#
# The number therefore lags by however often this runs. That is not a bug; it
# is how a 1997 counter behaved when the webmaster regenerated the page.
#
# Environment:
#   GOATCOUNTER_CODE   the subdomain part of MYCODE.goatcounter.com   (required)
#   GOATCOUNTER_TOKEN  an API token with "read statistics" scope      (required)
#   PAGE               file to rewrite, default index.html
#
# Exits 0 and changes nothing if the count cannot be read, so a scheduled run
# never leaves a broken number in the page.

set -euo pipefail

PAGE="${PAGE:-index.html}"

if [ -z "${GOATCOUNTER_CODE:-}" ] || [ -z "${GOATCOUNTER_TOKEN:-}" ]; then
  echo "bake-counter: GOATCOUNTER_CODE or GOATCOUNTER_TOKEN not set, skipping." >&2
  exit 0
fi

if [ ! -f "${PAGE}" ]; then
  echo "bake-counter: ${PAGE} not found." >&2
  exit 1
fi

API="https://${GOATCOUNTER_CODE}.goatcounter.com/api/v0/stats/total"

BODY="$(curl -fsS --max-time 20 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${GOATCOUNTER_TOKEN}" \
  "${API}")" || {
    echo "bake-counter: API request failed, leaving the page alone." >&2
    exit 0
  }

# GoatCounter's response shape for this endpoint is not pinned in its docs, so
# take the first plausible integer field rather than assuming one key.
COUNT="$(printf '%s' "${BODY}" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(1)
for k in ("total", "count", "total_events", "hits"):
    v = d.get(k) if isinstance(d, dict) else None
    if isinstance(v, int):
        print(v); sys.exit(0)
if isinstance(d, dict):
    for v in d.values():
        if isinstance(v, int):
            print(v); sys.exit(0)
sys.exit(1)
')" || {
    echo "bake-counter: could not find a count in the response:" >&2
    printf '%s\n' "${BODY}" >&2
    exit 0
  }

PADDED="$(printf '%07d' "${COUNT}")"

python3 - "${PAGE}" "${PADDED}" <<'PY'
import re, sys
page, padded = sys.argv[1], sys.argv[2]
s = open(page, encoding="utf-8").read()
new, n = re.subn(r"(<!--HITS-->)\d*(<!--/HITS-->)",
                 lambda m: m.group(1) + padded + m.group(2), s)
if n != 1:
    sys.exit(f"bake-counter: expected exactly one HITS marker pair, found {n}")
if new != s:
    open(page, "w", encoding="utf-8").write(new)
    print(f"bake-counter: {page} -> {padded}")
else:
    print(f"bake-counter: already {padded}, unchanged")
PY
