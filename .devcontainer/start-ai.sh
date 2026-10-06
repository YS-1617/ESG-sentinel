#!/usr/bin/env bash
# Starts the AI service on every codespace start and makes port 8000 public
# so the Render backend can reach it.
cd "$(dirname "$0")/../ai-service"

mkdir -p uploads data/reports data/evidence data/processed data/indexes data/evaluation data/outputs

# Stop an old instance if one is still running.
pkill -f "uvicorn main:app" 2>/dev/null || true

setsid nohup python -m uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 \
  > /tmp/ai-service.log 2>&1 < /dev/null &
disown

# Wait for the service, then try to make the port public.
for _ in $(seq 1 60); do
  curl -sf http://127.0.0.1:8000/health > /dev/null && break
  sleep 2
done

if [ -n "$CODESPACE_NAME" ]; then
  gh codespace ports visibility 8000:public -c "$CODESPACE_NAME" 2>/dev/null \
    || echo "Could not set port 8000 to public automatically - set it in the Ports tab."
  echo "AI service URL: https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi
echo "Logs: tail -f /tmp/ai-service.log"
