#!/bin/bash

DELETES=(VERSION src build lib include share lib64 bin64)

function delete_target() {
  f=$1
  echo "clean $f"
  for d in "${DELETES[@]}"; do
    [ -e "$f/$d" ] && echo "delete $f/$d" && rm -rf "${f:?}/${d:?}"
  done
}

if [ "X$1" == "X" ]; then
  for f in *; do
    [ -e "$f/check.cmake" ] && {
      delete_target "$f"
    }
  done
else
  delete_target "$1"
fi

exit 0
