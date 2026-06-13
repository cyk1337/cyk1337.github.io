#!/usr/bin/env bash
#
# Failover deploy: build the site locally and publish _site directly to the
# GitHub Pages repo, bypassing GitHub Actions. Use this when Actions minutes
# are exhausted or the deploy workflow is otherwise unavailable.
#
# It mirrors .github/workflows/deploy.yml:
#   - JEKYLL_ENV=production
#   - tolerate the known Ruby SEGV during cleanup if _site/index.html exists
#   - purge unused CSS
#   - publish _site to cyk1337/cyk1337.github.io (history preserved)
#
# Usage:
#   ./deploy_failover.sh           # build + deploy
#   DRY_RUN=1 ./deploy_failover.sh # build + stage, skip the final push
#
set -euo pipefail

PAGES_REPO="${PAGES_REPO:-git@github.com:cyk1337/cyk1337.github.io.git}"
PAGES_BRANCH="${PAGES_BRANCH:-main}"
DRY_RUN="${DRY_RUN:-0}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="$REPO_ROOT/_site"

# Ruby defaults to US-ASCII in some shells; the bibliography contains non-ASCII
# author names, so force UTF-8 to avoid jekyll-scholar crashes.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export JEKYLL_ENV=production

echo "==> Building site (production)…"
bundle exec jekyll build || {
  if [ -d "$SITE_DIR" ] && [ -f "$SITE_DIR/index.html" ]; then
    echo "warning: build finished but Ruby crashed during cleanup (known SEGV). Continuing."
  else
    echo "error: build failed." >&2
    exit 1
  fi
}

echo "==> Purging unused CSS…"
if command -v purgecss >/dev/null 2>&1; then
  purgecss -c purgecss.config.js || echo "warning: purgecss failed; continuing with unpurged CSS."
else
  echo "note: purgecss not installed; skipping (npm i -g purgecss to enable)."
fi

# GitHub Pages needs CNAME (custom domain) and .nojekyll preserved in the output.
[ -f "$REPO_ROOT/CNAME" ] && cp "$REPO_ROOT/CNAME" "$SITE_DIR/CNAME"
touch "$SITE_DIR/.nojekyll"

echo "==> Publishing _site to $PAGES_REPO ($PAGES_BRANCH)…"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
git clone --depth 1 --branch "$PAGES_BRANCH" "$PAGES_REPO" "$WORK"

# Sync built output into the checkout, preserving the .git directory.
rsync -a --delete --exclude='.git' "$SITE_DIR"/ "$WORK"/

cd "$WORK"
git add -A
if git diff --staged --quiet; then
  echo "==> No changes to deploy."
  exit 0
fi

git -c user.name="cyk1337" \
    -c user.email="13767887+cyk1337@users.noreply.github.com" \
    commit -q -m "Deploy $(date -u '+%Y-%m-%dT%H:%M:%SZ') (failover)"

if [ "$DRY_RUN" = "1" ]; then
  echo "==> DRY_RUN=1: built and staged, skipping push. Working copy: $WORK"
  trap - EXIT
  exit 0
fi

git push origin "$PAGES_BRANCH"
echo "==> Done."
