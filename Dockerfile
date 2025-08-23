FROM python:3.10-slim-bullseye

WORKDIR /app

COPY requirements.txt .

# 安装 Python 依赖 + Chromium 最小运行依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
      # Chromium 运行必要库
      libnss3 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
      libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 \
      libxss1 libxtst6 libglib2.0-0 libgtk-3-0 libdrm2 libdbus-1-3 \
      libgbm1 libxshmfence1 libasound2 \
      # 时区（可选）
      tzdata \
    && pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ \
    && playwright install chromium \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apt-get purge -y --auto-remove tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . .

# 默认启动常驻进程
CMD ["python", "schedule_main.py"]
