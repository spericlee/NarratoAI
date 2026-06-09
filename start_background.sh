#!/bin/bash

# NarratoAI 后台启动脚本
# 功能：在后台运行 Streamlit 服务

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  NarratoAI 后台启动"
echo "========================================="
echo ""

# 检查是否已经在运行
if pgrep -f "streamlit run webui.py" > /dev/null; then
    echo "⚠️  Streamlit 已在运行中"
    echo "   PID: $(pgrep -f 'streamlit run webui.py')"
    echo ""
    echo "如需重启，请先运行: ./stop.sh"
    exit 1
fi

# 激活虚拟环境并后台启动
source venv/bin/activate

# 创建日志目录
mkdir -p logs

# 后台启动 Streamlit
nohup streamlit run webui.py --server.maxUploadSize=2048 > logs/streamlit.log 2>&1 &

STREAMLIT_PID=$!
echo "✅ Streamlit 已启动 (PID: $STREAMLIT_PID)"
echo ""
echo "访问地址:"
echo "  本地: http://localhost:8501"
echo "  局域网: http://$(hostname -I | awk '{print $1}'):8501"
echo ""
echo "查看日志: tail -f logs/streamlit.log"
echo "停止服务: ./stop.sh"
echo ""