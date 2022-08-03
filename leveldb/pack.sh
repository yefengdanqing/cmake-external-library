#!/bin/bash
BASE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

COMMIT_ID=99b3c03b3284f5886f9ef9a4ef703d57373e61be
REPO="https://github.com/google/leveldb.git"
bash "$BASE/../scripts/pack_git_repo.sh" -r ${REPO} -v leveldb-submodule-${COMMIT_ID} \
  -c ${COMMIT_ID} -w ${BASE}/tmp
