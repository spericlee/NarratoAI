# NarratoAI 快速启动指南

## 🚀 一键启动

### 方式一：使用启动脚本（推荐）

```bash
# 启动服务
./start.sh

# 访问地址
# http://localhost:8501
```

### 方式二：手动启动

```bash
# 1. 激活虚拟环境
source venv/bin/activate

# 2. 启动应用
streamlit run webui.py --server.maxUploadSize=2048
```

## 🛑 停止服务

### 方式一：使用停止脚本

```bash
./stop.sh
```

### 方式二：手动停止

在运行 Streamlit 的终端按 `Ctrl+C`

## 📋 首次使用

1. **运行启动脚本**
   ```bash
   ./start.sh
   ```

2. **配置 API 密钥**
   - 脚本会自动从 `config.example.toml` 创建 `config.toml`
   - 编辑 `config.toml` 文件，添加必要的 API 密钥：
     - LLM API Key（OpenAI/Gemini/Qwen等）
     - TTS API Key（如使用云服务）
   
3. **重新启动**
   ```bash
   ./start.sh
   ```

## 🔧 常见问题

### 1. 权限问题

如果提示权限不足：
```bash
chmod +x start.sh stop.sh
```

### 2. 依赖安装失败

脚本会自动处理依赖安装，如果仍然失败：
```bash
# 手动安装系统依赖
sudo apt install libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7-dev libtiff5-dev libwebp-dev

# 重新安装 Python 依赖
source venv/bin/activate
pip install "Pillow>=11.0.0" -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --no-deps Pillow
```

### 3. ffmpeg 未安装

视频处理需要 ffmpeg：
```bash
sudo apt install ffmpeg
```

### 4. 端口被占用

如果 8501 端口被占用，可以指定其他端口：
```bash
streamlit run webui.py --server.port 8502 --server.maxUploadSize=2048
```

## 📁 项目结构

```
NarratoAI/
├── start.sh              # 一键启动脚本
├── stop.sh               # 停止服务脚本
├── venv/                 # Python 虚拟环境（自动生成）
├── config.toml           # 配置文件（首次运行自动创建）
├── config.example.toml   # 配置示例
├── requirements.txt      # Python 依赖
├── webui.py             # Web 界面入口
└── storage/             # 存储目录（视频、音频等）
```

## 💡 提示

- 首次运行会自动创建虚拟环境并安装依赖，请耐心等待
- 使用国内镜像源加速下载，速度更快
- 建议定期备份 `config.toml` 和 `storage/` 目录
- 遇到问题可查看日志输出或提交 Issue

## 🌐 访问地址

启动成功后，在浏览器中访问：
- **本地访问**: http://localhost:8501
- **局域网访问**: http://你的IP:8501
