#!/bin/sh
: "${BATCH:=0}"

ask_continue() {
  if [ "${BATCH:-}" != 1 ]; then
    printf '%s' "continue? [y/N] "
    read -r ans
    if [ "$ans" != y ]; then
      echo "backing off"
      exit 2
    fi
  fi
}
