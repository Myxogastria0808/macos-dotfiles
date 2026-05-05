#!/usr/bin/env bash
set -euo pipefail

if ! command -v ollama &>/dev/null; then
	echo "Error: Ollama is not installed."
	exit 1
fi

open -a Ollama
echo "Waiting for Ollama to start..."
until ollama list &>/dev/null; do sleep 0.5; done

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

pull_model() {
	local model="$1"
	ollama pull "$model" 2>&1 | tr '\r' '\n' | grep -v '^[[:space:]]*$' | sed "s/^/[$model] /"
}

for model in "${models[@]}"; do
	pull_model "$model" &
done

wait

