#!/bin/bash

# NarratoAI 一键启动脚本
# 功能：自动检查环境、激活虚拟环境并启动应用

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_info "========================================="
print_info "  NarratoAI 一键启动脚本"
print_info "========================================="
echo ""

# 检查 Python 是否安装
if ! command -v python3 &> /dev/null; then
    print_error "未找到 Python3，请先安装 Python 3.12+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
print_success "检测到 Python 版本: $PYTHON_VERSION"

# 检查虚拟环境是否存在
if [ ! -d "venv" ]; then
    print_warning "虚拟环境不存在，正在创建..."
    python3 -m venv venv
    print_success "虚拟环境创建成功"
fi

# 检查关键依赖是否已安装
if [ ! -f "venv/bin/streamlit" ]; then
    print_warning "依赖未安装，正在安装（使用国内镜像源）..."
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 先升级 pip
    pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
    
    # 安装系统依赖（如果需要）
    if ! dpkg -l | grep -q libjpeg-dev; then
        print_info "安装系统级依赖..."
        sudo apt update
        sudo apt install -y libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7-dev libtiff5-dev libwebp-dev
    fi
    
    # 先安装 Pillow（兼容 Python 3.14）
    pip install "Pillow>=11.0.0" -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
    
    # 安装其他依赖
    pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-deps Pillow
    
    print_success "依赖安装完成"
else
    print_success "虚拟环境和依赖已就绪"
fi

# 检查配置文件
if [ ! -f "config.toml" ]; then
    print_warning "配置文件 config.toml 不存在"
    if [ -f "config.example.toml" ]; then
        print_info "从示例配置创建 config.toml..."
        cp config.example.toml config.toml
        print_warning "请编辑 config.toml 文件，添加必要的 API 密钥"
        print_info "按回车键继续，或按 Ctrl+C 取消..."
        read
    else
        print_error "找不到 config.example.toml，请先创建配置文件"
        exit 1
    fi
fi

# 激活虚拟环境
print_info "激活虚拟环境..."
source venv/bin/activate

# 创建 Streamlit 配置目录并禁用遥测
mkdir -p ~/.streamlit
cat > ~/.streamlit/config.toml << EOF
[browser]
gatherUsageStats = false
EOF

# 检查 ffmpeg 是否可用
if ! command -v ffmpeg &> /dev/null; then
    print_warning "ffmpeg 未安装，视频处理可能失败"
    print_info "建议安装: sudo apt install ffmpeg"
fi

# 启动 Streamlit 应用
print_success "========================================="
print_success "  启动 NarratoAI Web UI"
print_success "========================================="
print_info "访问地址: http://localhost:8501"
print_info "按 Ctrl+C 停止服务"
echo ""

streamlit run webui.py --server.maxUploadSize=2048
