#!/bin/bash
# package git repo, in purpose of speeding up downloads in china mainland.

set -ex
BASE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
function usage() {
  cat <<EOF
    $0 -r <git-repo-url> -v <target-name-version> [-b branch / -t tag / -c commit-id]
EOF
}

VERSION=
TARGET_NAME_VERSION=
REPO=
WKD="$BASE/tmp"
# retrieve version from parameters
while getopts "r:v:c:t:b:w:" OPTION; do
  case "$OPTION" in
  c)
    VERSION="$OPTARG";;
  t)
    VERSION="tags/$OPTARG";;
  b)
    VERSION="$OPTARG";;
  r)
    REPO="$OPTARG";;
  v)
    TARGET_NAME_VERSION="$OPTARG";;
  w)
    WKD="$OPTARG";;
  *)
    usage
    exit 1
    ;;
  esac
done

echo "Pack repo. [target_name_version=$TARGET_NAME_VERSION, target_version=$VERSION, repo=$REPO}]"

# check parameters
if [ "X$TARGET_NAME_VERSION" = "X" ] || [ "X$VERSION" = "X" ] || [ "X$REPO" = "X" ]; then
  usage
  exit 1
fi

# enter work directory
mkdir -p "$WKD"
cd "$WKD" || exit 1

# clone, package and clean up
git clone --recurse-submodule "$REPO" "$TARGET_NAME_VERSION"
git -C "$TARGET_NAME_VERSION" checkout "$VERSION"
tar -czf "$TARGET_NAME_VERSION.tar.gz" --exclude "\.git" --exclude "\.github" "$TARGET_NAME_VERSION"/*
rm -rf "$TARGET_NAME_VERSION"
