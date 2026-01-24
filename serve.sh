lsof -i:4000 | awk '{print $2}'| xargs -I {} kill -9 {}


# bundle exec jekyll serve  --incremental
bundle exec jekyll serve --trace --verbose &
