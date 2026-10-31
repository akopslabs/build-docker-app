#!/usr/bin/env bash
# AkOps Labs check for the Docker project. Please don't edit this file.
set -uo pipefail
fail=0
pass() { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
IMAGE=akops-check-app:test

[ -f Dockerfile ] && pass "Dockerfile exists" || { bad "Dockerfile exists in the repo root"; exit 1; }
[ -f .dockerignore ] && pass ".dockerignore exists" || bad ".dockerignore exists"
grep -Eiq '^FROM\s+node:(2[0-9])[-.0-9a-z]*-?(alpine|slim)' Dockerfile && pass "small Node 20+ base image (alpine or slim)" || bad "FROM a node:20+ alpine or slim image"
grep -Eiq '^\s*USER\s+' Dockerfile && pass "runs as a non-root USER" || bad "Dockerfile sets a non-root USER"
grep -Eiq '^\s*HEALTHCHECK\s' Dockerfile && pass "has a HEALTHCHECK" || bad "Dockerfile has a HEALTHCHECK"
grep -Eiq '^\s*EXPOSE\s+3000' Dockerfile && pass "EXPOSE 3000" || bad "Dockerfile exposes port 3000"

docker build -t "$IMAGE" . >/tmp/build.log 2>&1 && pass "image builds" || { bad "image builds (see the log below)"; tail -30 /tmp/build.log; exit 1; }
size=$(docker image inspect "$IMAGE" --format '{{.Size}}')
[ "$size" -lt 250000000 ] && pass "image is smaller than 250 MB ($((size/1000000)) MB)" || bad "image is smaller than 250 MB ($((size/1000000)) MB)"

docker rm -f akops-check >/dev/null 2>&1
docker run -d --name akops-check -p 3000:3000 -e APP_NAME=check "$IMAGE" >/dev/null && pass "container starts" || bad "container starts"
for _ in $(seq 1 20); do curl -fs localhost:3000/health >/dev/null && break; sleep 1; done
curl -fs localhost:3000/health | grep -q '"status":"ok"' && pass "GET /health returns ok" || bad "GET /health returns ok"
uid=$(docker exec akops-check id -u 2>/dev/null || echo "?")
[ "$uid" != "0" ] && [ "$uid" != "?" ] && pass "process is not root (uid $uid)" || bad "process is not root (uid $uid)"
for _ in $(seq 1 40); do st=$(docker inspect -f '{{.State.Health.Status}}' akops-check 2>/dev/null); [ "$st" = healthy ] && break; sleep 1; done
[ "${st:-}" = healthy ] && pass "Docker reports the container healthy" || bad "Docker reports the container healthy (status: ${st:-none})"
docker rm -f akops-check >/dev/null 2>&1

echo
[ $fail -eq 0 ] && echo "All checks passed. Push and submit your repo on AkOps Labs." || echo "Some checks failed. Fix them and push again."
exit $fail
