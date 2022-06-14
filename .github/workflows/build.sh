#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# set -euxo pipefail

DATE="$(echo $(TZ=UTC date '+%Y-%m-%d %H:%M:%S'))"
USER=$(whoami)
TMP_DIR="${TMP_DIR:-$(mktemp -d /tmp/tian.XXXX)}"
LOG_FILE="${LOG_FILE:-${TMP_DIR}/build.log}"
head_start="<\!--ts-->"
head_end="<\!--te-->"

repoArr=("Ash258/Scoop-JetBrains" "ScoopInstaller/Java" "ScoopInstaller/Extras" "ScoopInstaller/Main" "ScoopInstaller/Versions" "matthewjberger/scoop-nerd-fonts" "jonz94/scoop-sarasa-nerd-fonts" "kodybrown/scoop-nirsoft" "Ryanjiena/Meta")
branchArr=("main" "master" "master" "master" "master" "master" "master" "master" "master")
dirArr=("jetbrains" "java" "extras" "main" "versions" "nerd-fonts" "sarasa-nerd-fonts" "nirsoft" "meta")

# clone tian and fantastic-bucket repo
git clone -q --depth=1 --branch="main" https://Ryanjiena:${github_token}@github.com/Ryanjiena/tian.git "${TMP_DIR}/tian"
git clone -q --depth=1 --branch="main" https://Ryanjiena:${github_token}@github.com/Ryanjiena/fantastic-bucket.git "${TMP_DIR}/fantastic"

# init tian
cd "${TMP_DIR}/tian"
if [ -d "bucket" ]; then
    rm -rf bin bucket scripts README.md
fi

# init fantastic-bucket
cd "${TMP_DIR}/fantastic"
if [ -d "bucket" ]; then
    rm -rf bin bucket scripts README.md
fi

# build
manifest_badge="| Bucket | Manifest |\n| :--- | :--- |\n"
for ((i = 2; i < ${#repoArr[@]}; i++)); do

    if [[ "$i" != "0" ]]; then
        git clone -q --depth=1 --branch="${branchArr[i]}" "https://github.com/${repoArr[i]}.git" "${TMP_DIR}/${dirArr[i]}"
    else
        git clone -q --depth=1 --branch="${branchArr[i]}" "https://Ryanjiena:${github_token}@github.com/${repoArr[i]}.git" "${TMP_DIR}/${dirArr[i]}"
    fi

    cd "${TMP_DIR}/${dirArr[i]}/bucket"
    manifest_num="$(ls *.json | wc -l)"
    manifest_badge="${manifest_badge} | [${repoArr[i]}](https://github.com/${repoArr[i]}.git) | [![${repoArr[i]} badge](https://img.shields.io/badge/${repoArr[i]}-${manifest_num}-green.svg)](https://github.com/${repoArr[i]}.git) |\n"

    # rename manifest
    # https://unix.stackexchange.com/a/56812
    # date; for filename in *.json; do mv "${filename}" "${filename%.json}_${dirArr[i]}.json"; done; date
    # rename "s/\.json$/_${dirArr[i]}.json/" *json
    rename 'y/A-Z/a-z/' *json
    sed -i "s|bucketsdir\\\\\\\\${dirArr[i]}\\\\\\\\scripts|bucketsdir\\\\\\\\tian\\\\\\\\scripts|g" *json

    # copy bucket/scripts folder
    cd "${TMP_DIR}/${dirArr[i]}"
    cp bucket/*.json ${TMP_DIR}/tian/bucket/ -n
    if [ -e "scripts" ]; then
        cp scripts/* ${TMP_DIR}/tian/scripts/ -r -n
    fi

done

# copy bin folder to tian
cp ${TMP_DIR}/main/bin/* ${TMP_DIR}/tian/bin/ -f

# replace head
sed -i "/${head_start}/,/${head_end}/{//!d;}" "${TMP_DIR}/tian/README.md"
echo -e  "${manifest_badge}" > "${TMP_DIR}/head.md"
sed -i "/${head_start}/r ${TMP_DIR}/head.md" "${TMP_DIR}/tian/README.md"

# Copy tian to fantastic-bucket
cp ${TMP_DIR}/tian/bucket/* ${TMP_DIR}/fantastic/bucket/
cp ${TMP_DIR}/tian/scripts/* ${TMP_DIR}/fantastic/scripts/ -r
cp ${TMP_DIR}/tian/bin/* ${TMP_DIR}/fantastic/bin/
cp ${TMP_DIR}/tian/README.md ${TMP_DIR}/fantastic/README.md -f

# remove cracked
cd "${TMP_DIR}/tian/bucket"
grep -l "pan.jiemi.workers.dev" *.json | xargs -I {} rm {}

# push
cd "${TMP_DIR}/tian" && git add . && git commit -m "Update ${DATE} by ${USER}" && git push origin main
cd "${TMP_DIR}/fantastic" && git add . && git commit -m "Update ${DATE} by ${USER}" && git push origin main
