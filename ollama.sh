#!/usr/bin/env bash
set -euo pipefail

if ! command -v ollama &>/dev/null; then
	echo "Error: Ollama is not installed."
	exit 1
fi

open -a Ollama
echo "Waiting for Ollama to start..."
until ollama list &>/dev/null; do sleep 0.5; done

ollama pull qwen3.5:0.8b
ollama pull qwen3.5:2b
ollama pull qwen3.5:4b
ollama pull qwen3.5:9b
ollama pull qwen3.5:27b
ollama pull qwen3.5:35b
ollama pull qwen3.5:122b
ollama pull qwen3.6:27b
ollama pull qwen3.6:35b

