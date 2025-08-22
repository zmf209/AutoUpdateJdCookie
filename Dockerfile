# ========================
# Stage 1: Builder
# ========================
FROM python:3.10-slim-bullseye AS builder

WORKDIR /app

# 安装最小依赖 + Python 包
RUN apt-get update && apt-get install -y --no-install-recommends \
      libnss3 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
      libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 \
      libxss1 libxtst6 libglib2.0-0 libgtk-3-0 libdrm2 libdbus-1-3 \
      libgbm1 libxshmfence1 libasound2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# 安装 Python 依赖 + Chromium
RUN pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ \
    && playwright install chromium

# 复制代码
COPY . .

# ========================
# Stage 2: Runtime
# ========================
FROM python:3.10-slim-bullseye AS runtime

WORKDIR /app

# 安装最小依赖（运行 Chromium 必需库）
RUN apt-get update && apt-get install -y --no-install-recommends \
      libnss3 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
      libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 \
      libxss1 libxtst6 libglib2.0-0 libgtk-3-0 libdrm2 libdbus-1-3 \
      libgbm1 libxshmfence1 libasound2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 从 builder 拷贝 Python 依赖和 Chromium
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# 默认启动常驻进程
CMD ["python", "schedule_main.py"]
