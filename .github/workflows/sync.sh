#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# set -euxo pipefail

CURRENT_DIR="$(pwd)"
DATE="$(echo $(TZ=UTC date '+%Y-%m-%d %H:%M:%S'))"
USER=$(whoami)

git clone -q --depth=1 git@jihulab.com:Ryanjie/Tian.git "${CURRENT_DIR}/tian-cn"
git clone -q --depth=1 https://Ryanjiena:${github_token}@github.com/Ryanjiena/fantastic-bucket.git "${CURRENT_DIR}/fantastic"

cd ${CURRENT_DIR}/fantastic/bucket/
# sed -i 's|\(https://github.com/.*/releases/download\)|https://ghproxy.com/\1|g;s|\(https://github.com/.*/archive\)|https://ghproxy.com/\1|g;s|\(https://raw.githubusercontent.com/\)|https://ghproxy.com/\1|g' *json

cd ${CURRENT_DIR}/tian-cn/
if [ -d "bucket" ]; then
    rm -rf bin bucket scripts README.md
fi

cp ${CURRENT_DIR}/fantastic/bin/* ${CURRENT_DIR}/tian-cn/bin/ -f
cp ${CURRENT_DIR}/fantastic/bucket/* ${CURRENT_DIR}/tian-cn/bucket/ -f
cp ${CURRENT_DIR}/fantastic/scripts/* ${CURRENT_DIR}/tian-cn/scripts/ -r -f
cp ${CURRENT_DIR}/fantastic/README.md ${CURRENT_DIR}/tian-cn/README.md -f

git add . && git commit -m "Sync by: ${USER}, at: ${DATE}"
git push -u origin main
