#!/usr/bin/env zsh
set -euo pipefail

if ! command -v ollama &>/dev/null; then
	echo "Error: Ollama is not installed."
	exit 1
fi

if ! curl -sf http://localhost:11434 &>/dev/null; then
	echo "Error: Ollama is not running. Please start Ollama first."
	exit 1
fi

find ~/.ollama/models/blobs -name '*-partial*' -delete 2>/dev/null

models=(
	qwen3.5:0.8b
	qwen3.5:2b
	qwen3.5:4b
	qwen3.5:9b
	qwen3.5:27b
	qwen3.5:35b
	qwen3.5:122b
	qwen3.6:27b
	qwen3.6:35b
)

for model in "${models[@]}"; do
	if ollama list | awk 'NR>1 {print $1}' | grep -qxF "$model"; then
		echo "[$model] already exists, skipping"
		continue
	fi
	echo "Pulling $model..."
	if ollama pull "$model"; then
		echo "[$model] success"
	else
		echo "[$model] failed, skipping"
	fi
done

