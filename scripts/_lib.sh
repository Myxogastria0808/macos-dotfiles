#!/usr/bin/env bash

ok()     { printf "  \033[0;32m✓\033[0m  %s\n" "$*"; }
skip()   { printf "  \033[0;33m–\033[0m  %s\n" "$*"; }
err()    { printf "  \033[0;31m✗\033[0m  %s\n" "$*" >&2; }
action() { printf "  \033[1;35m!\033[0m  \033[1;35m%s\033[0m\n" "$*"; }
