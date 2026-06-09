#!/bin/bash

# NarratoAI 停止脚本
# 功能：停止正在运行的 Streamlit 服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "查找并停止 NarratoAI (Streamlit) 进程..."

# 查找 streamlit 进程
PIDS=$(pgrep -f "streamlit run webui.py")

if [ -z "$PIDS" ]; then
    print_warning "未找到运行中的 NarratoAI 进程"
    exit 0
fi

print_info "找到以下进程:"
echo "$PIDS" | while read pid; do
    echo "  PID: $pid - $(ps -p $pid -o args=)"
done

echo ""

# 直接停止，不需要确认（适合后台服务）
print_info "正在停止进程..."
echo "$PIDS" | while read pid; do
    kill $pid 2>/dev/null || true
done

# 等待进程结束
sleep 2

# 检查是否还有残留进程
REMAINING_PIDS=$(pgrep -f "streamlit run webui.py")
if [ -n "$REMAINING_PIDS" ]; then
    print_warning "强制终止残留进程..."
    echo "$REMAINING_PIDS" | while read pid; do
        kill -9 $pid 2>/dev/null || true
    done
fi

print_success "NarratoAI 已停止"
