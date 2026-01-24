#!/bin/bash

set -x

# 构建网站
bundle exec jekyll build --incremental

# 设置部署目录（在项目外部）
DEPLOY_DIR="../cyk1337.github.io-deploy"

# 如果部署目录不存在，克隆远程仓库
if [ ! -d "$DEPLOY_DIR" ]; then
  echo "First time setup: cloning repository..."
  git clone --depth 1 git@github.com:cyk1337/cyk1337.github.io.git "$DEPLOY_DIR"
fi

# 进入部署目录
cd "$DEPLOY_DIR"

# 拉取最新的远程分支（只拉取最新提交，节省时间）
git pull origin main --rebase

# 删除所有文件（除了 .git）
find . -maxdepth 1 ! -name '.git' ! -name '.' ! -name '..' -exec rm -rf {} +

# 复制新生成的文件
cp -r ../gh_site/_site/* .

# 检查是否有改动
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to deploy"
  exit 0
fi

# 提交并推送改动
git add -A
git commit -m ":elephant: update $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
