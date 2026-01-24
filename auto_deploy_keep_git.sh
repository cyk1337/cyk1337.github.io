#!/bin/bash

set -x

# 备份 _site/.git（如果存在）
if [ -d "_site/.git" ]; then
  mv _site/.git /tmp/site_git_backup
fi

# 构建网站
bundle exec jekyll build --incremental

# 恢复 .git
if [ -d "/tmp/site_git_backup" ]; then
  mv /tmp/site_git_backup _site/.git
fi

cd _site

# 如果没有 .git，初始化
if [ ! -d ".git" ]; then
  echo "First time setup: initializing repository..."
  git clone --depth 1 git@github.com:cyk1337/cyk1337.github.io.git temp_clone
  mv temp_clone/.git .
  rm -rf temp_clone
fi

# 检查是否有改动
git add -A
if git diff --staged --quiet; then
  echo "No changes to deploy"
  exit 0
fi

# 提交并推送
git commit -m ":elephant: update $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
