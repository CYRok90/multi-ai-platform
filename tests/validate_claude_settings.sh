#!/usr/bin/env bash
# Regression test for validate_claude_settings — root cause incident:
# Claude Code 2.1.118 in CommandCenter PTY froze stdin when
# .claude/settings.local.json contained Bash(...) entries with unmatched
# quotes (rendered an invisible Settings dialog). aib v1.0.1 added a
# pre-launch check; this test pins that behavior.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AIB_BIN="${SCRIPT_DIR}/../bin/aib"

fail() { echo "FAIL: $1"; exit 1; }

[ -x "$AIB_BIN" ] || fail "$AIB_BIN not executable"

# Extract helpers + validate_claude_settings into a temp file we can source.
# Bound by line numbers of the colors block start ("RED='...'") and the next
# function definition (client_name) — re-derived dynamically so refactors
# don't silently break this test.
HELPERS=$(mktemp)
trap 'rm -f "$HELPERS"' EXIT
start=$(grep -n "^RED='" "$AIB_BIN" | head -1 | cut -d: -f1)
end=$(grep -n "^client_name()" "$AIB_BIN" | head -1 | cut -d: -f1)
[ -n "$start" ] && [ -n "$end" ] && [ "$end" -gt "$start" ] || fail "could not locate function boundaries in $AIB_BIN"
sed -n "${start},$((end-1))p" "$AIB_BIN" > "$HELPERS"

run_in() {
    local dir="$1"
    ( cd "$dir" && bash -c "source '$HELPERS'; validate_claude_settings 2>&1" )
}

# --- Case 1: broken patterns are detected ---
T1=$(mktemp -d)
mkdir -p "$T1/.claude"
cat > "$T1/.claude/settings.local.json" <<'EOF'
{
  "permissions": {
    "allow": [
      "Bash(ls -la)",
      "Bash(.venv/bin/python -c \":*)",
      "Bash(gh release create v0 --notes ':*)",
      "WebFetch(domain:example.com)"
    ]
  }
}
EOF
out=$(run_in "$T1")
rm -rf "$T1"
echo "$out" | grep -q "2 broken Bash" || fail "case 1: expected '2 broken Bash' in output:\n$out"
echo "PASS case 1: detects 2 unmatched-quote Bash patterns"

# --- Case 2: clean file is silent ---
T2=$(mktemp -d)
mkdir -p "$T2/.claude"
cat > "$T2/.claude/settings.local.json" <<'EOF'
{"permissions":{"allow":["Bash(ls)","Bash(grep -n \"foo\")","WebFetch(domain:x)"]}}
EOF
out=$(run_in "$T2")
rm -rf "$T2"
[ -z "$out" ] || fail "case 2: clean settings produced output:\n$out"
echo "PASS case 2: clean settings produce no output"

# --- Case 3: missing file is silent ---
T3=$(mktemp -d)
out=$(run_in "$T3")
rm -rf "$T3"
[ -z "$out" ] || fail "case 3: missing file produced output:\n$out"
echo "PASS case 3: missing settings produce no output"

echo "ALL PASS"
