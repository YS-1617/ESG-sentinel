#!/usr/bin/env bash
# One-time install for the AI service (runs when the codespace is created).
set -e
cd "$(dirname "$0")/../ai-service"

python -m pip install --upgrade pip
# CPU-only torch (same library, no CUDA download), then the project's pinned requirements.
python -m pip install torch --index-url https://download.pytorch.org/whl/cpu
python -m pip install -r requirements.txt

# Cache the embedding model so the first analysis is not slow.
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')"
