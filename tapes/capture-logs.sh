#!/usr/bin/env bash
# GIF と同じコマンド列を実行して、生の出力を recordings/*.log に残す。
set -u
export PATH="$HOME/.ant/bin:$HOME/.bun/bin:/opt/homebrew/bin:/usr/bin:/bin"
cd "$(dirname "$0")/.."
mkdir -p recordings dist /tmp/standalone

strip() { LC_ALL=C sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g'; }
serve() { "$@" >/tmp/serve.log 2>&1 & echo $! >/tmp/serve.pid; sleep 1.5; }
stop()  { kill "$(cat /tmp/serve.pid)" 2>/dev/null; sleep 0.5; }
say()   { printf '$ %s\n' "$1"; }

# ---- 01: run ----
{
  say 'ant --version';            ant --version 2>&1 | strip; echo
  say 'ant src/server.ts &';      serve ant src/server.ts
  say "curl -s -w '\\n' localhost:8080/";      curl -s -w '\n' localhost:8080/
  say "curl -s -w '\\n' localhost:8080/json";  curl -s -w '\n' localhost:8080/json
  say 'bun ws-client.ts';         bun ws-client.ts
  echo '--- server log ---';      strip </tmp/serve.log
  stop
} > recordings/01-run.log

# ---- 02: compile ----
{
  say 'ant compile -o dist/server src/server.ts'; ant compile -o dist/server src/server.ts 2>&1 | strip | tail -2
  say 'ls -lh dist/server';       ls -lh dist/server; echo
  say 'cp dist/server /tmp/standalone/ && cd /tmp/standalone && ls -la'
  cp dist/server /tmp/standalone/ && (cd /tmp/standalone && ls -la)
  say './server &';               (cd /tmp/standalone && serve ./server)
  say "curl -s -w '\\n' localhost:8080/json";  curl -s -w '\n' localhost:8080/json
  say 'bun ws-client.ts';         bun ws-client.ts
  say 'otool -L server';          (cd /tmp/standalone && otool -L server)
  stop
} > recordings/02-compile.log

# ---- 03: sandbox ----
C1='{"code":"return [1,2,3].map(n => n * 2)"}'
C2='{"code":"while (true) {}"}'
C3='{"code":"const fs = await import(\"ant:fs\"); return fs.readFile(\"/etc/hosts\").catch(e => e.message)"}'
{
  say 'ant src/index.ts &';       serve ant src/index.ts
  for c in "$C1" "$C2" "$C3"; do
    say "curl -s -w '\\n' -X POST localhost:8080/run -d '$c'"
    curl -s -w '\n' -X POST localhost:8080/run -d "$c"
  done
  echo '--- server log ---';      strip </tmp/serve.log | grep -v '^\['
  stop
} > recordings/03-sandbox.log

ls -la recordings/*.log
