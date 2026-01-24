#!/bin/bash

set -x

# 构建网站
bundle exec jekyll build --incremental

# 使用 ghp-import 推送（自动处理 git 历史）
# 首次使用需要安装: pip install ghp-import
ghp-import -n -p -f -r origin -b main -m ":elephant: update $(date '+%Y-%m-%d %H:%M:%S')" _site

# 说明：
# -n: 添加 .nojekyll 文件
# -p: push 到远程
# -f: force push（如果需要）
# -r origin: 远程名称
# -b main: 目标分支
# -m: commit 消息
