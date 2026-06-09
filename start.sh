#!/bin/bash
# NarratoAI 启动脚本 - 转发到 run.py
# 使用方式: bash start.sh 或直接 python3 run.py

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/run.py"
