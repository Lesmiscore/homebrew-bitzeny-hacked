#!/bin/bash
set +e
find /patches | sort | tail -n+2 | while read line ; do
  echo "Patching $line"
  ( patch -p1 < $line ) || echo "Failed"
done
