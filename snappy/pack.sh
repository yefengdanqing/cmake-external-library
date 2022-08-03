#!/bin/bash
BASE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

TAG=1.1.9
bash "$BASE/../scripts/pack_git_repo.sh" -r https://github.com/google/snappy.git -v snappy-submodule-${TAG} -t ${TAG} \
  -w ${BASE}/tmp