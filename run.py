#!/usr/bin/env python3
"""NarratoAI Python 启动器 - 替代 start.sh，Ctrl+C 即可停止"""

import os
import sys
import subprocess
import signal
import shutil
import platform

# ---- 颜色输出 ----
COLORS = {
    "RED": "\033[0;31m",
    "GREEN": "\033[0;32m",
    "YELLOW": "\033[1;33m",
    "BLUE": "\033[0;34m",
    "NC": "\033[0m",
}

if platform.system() == "Windows":
    COLORS = {k: "" for k in COLORS}


def _wrap(color, text):
    return f"{COLORS[color]}{text}{COLORS['NC']}"


def info(msg):
    print(f"{_wrap('BLUE', '[INFO]')} {msg}")


def success(msg):
    print(f"{_wrap('GREEN', '[SUCCESS]')} {msg}")


def warning(msg):
    print(f"{_wrap('YELLOW', '[WARNING]')} {msg}")


def error(msg):
    print(f"{_wrap('RED', '[ERROR]')} {msg}")


# ---- 工具检查 ----
def _find_executable(name):
    return shutil.which(name)


def check_python():
    if not _find_executable("python3"):
        error("未找到 Python3，请先安装 Python 3.12+")
        sys.exit(1)
    ver = subprocess.check_output(["python3", "--version"], text=True).strip()
    success(f"检测到 Python 版本: {ver}")


def _run(cmd, **kw):
    return subprocess.run(cmd, **kw)


def _run_check(cmd, **kw):
    subprocess.run(cmd, check=True, **kw)


def setup_venv(script_dir):
    venv_bin = os.path.join(script_dir, "venv", "bin")
    streamlit_path = os.path.join(venv_bin, "streamlit")

    if not os.path.isdir(os.path.join(script_dir, "venv")):
        warning("虚拟环境不存在，正在创建...")
        _run_check(["python3", "-m", "venv", "venv"], cwd=script_dir)
        success("虚拟环境创建成功")

    if not os.path.isfile(streamlit_path):
        warning("依赖未安装，正在安装（使用国内镜像源）...")

        pip = os.path.join(venv_bin, "pip")
        if platform.system() == "Windows":
            pip = os.path.join(script_dir, "venv", "Scripts", "pip")

        upgrade_flags = [
            "-i", "https://mirrors.aliyun.com/pypi/simple/",
            "--trusted-host", "mirrors.aliyun.com",
        ]
        _run_check([pip, "install", "--upgrade", "pip", *upgrade_flags], cwd=script_dir)

        if platform.system() == "Linux":
            libjpeg = _run(
                ["dpkg", "-l"], cwd=script_dir,
                capture_output=True, text=True,
            )
            if "libjpeg-dev" not in libjpeg.stdout:
                info("安装系统级依赖...")
                _run_check(
                    ["sudo", "apt", "update"], cwd=script_dir
                )
                _run_check(
                    ["sudo", "apt", "install", "-y",
                     "libjpeg-dev", "zlib1g-dev", "libfreetype6-dev",
                     "liblcms2-dev", "libopenjp2-7-dev",
                     "libtiff5-dev", "libwebp-dev"],
                    cwd=script_dir,
                )

        _run_check(
            [pip, "install", "Pillow>=11.0.0", *upgrade_flags],
            cwd=script_dir,
        )
        _run_check(
            [pip, "install", "-r", "requirements.txt",
             *upgrade_flags, "--no-deps", "Pillow"],
            cwd=script_dir,
        )
        success("依赖安装完成")
    else:
        success("虚拟环境和依赖已就绪")

    return venv_bin


def check_config(script_dir):
    config_path = os.path.join(script_dir, "config.toml")
    example_path = os.path.join(script_dir, "config.example.toml")

    if not os.path.isfile(config_path):
        warning("配置文件 config.toml 不存在")
        if os.path.isfile(example_path):
            info("从示例配置创建 config.toml...")
            shutil.copy2(example_path, config_path)
            warning("请编辑 config.toml 文件，添加必要的 API 密钥")
            info("按回车键继续，或按 Ctrl+C 取消...")
            try:
                input()
            except KeyboardInterrupt:
                sys.exit(0)
        else:
            error("找不到 config.example.toml，请先创建配置文件")
            sys.exit(1)


def check_ffmpeg():
    if not _find_executable("ffmpeg"):
        warning("ffmpeg 未安装，视频处理可能失败")
        info("建议安装: sudo apt install ffmpeg")


def setup_streamlit_config():
    home = os.path.expanduser("~")
    sl_dir = os.path.join(home, ".streamlit")
    os.makedirs(sl_dir, exist_ok=True)
    config_file = os.path.join(sl_dir, "config.toml")
    content = "[browser]\ngatherUsageStats = false\n"
    with open(config_file, "w") as f:
        f.write(content)


def start(venv_bin, script_dir):
    python_path = os.path.join(venv_bin, "python")
    streamlit_module = "streamlit.web.cli"

    success("=========================================")
    success("  启动 NarratoAI Web UI")
    success("=========================================")
    info("访问地址: http://localhost:8501")
    info("按 Ctrl+C 停止服务")
    print()

    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"

    # 用 exec 方式启动，Ctrl+C 可以直接终止
    os.execve(
        python_path,
        [python_path, "-m", streamlit_module, "run",
         os.path.join(script_dir, "webui.py"),
         "--server.maxUploadSize=2048"],
        env,
    )


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    print(f"{_wrap('BLUE', '[INFO]')} {'='*37}")
    print(f"{_wrap('BLUE', '[INFO]')}   NarratoAI 一键启动脚本")
    print(f"{_wrap('BLUE', '[INFO]')} {'='*37}")
    print()

    check_python()
    venv_bin = setup_venv(script_dir)
    check_config(script_dir)
    check_ffmpeg()
    setup_streamlit_config()

    info("激活虚拟环境...")
    start(venv_bin, script_dir)


if __name__ == "__main__":
    main()
