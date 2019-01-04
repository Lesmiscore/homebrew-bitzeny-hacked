#!/bin/bash
set +e
find /patches -type f | sort | while read line ; do
  echo "Patching $line"
  ( patch -p1 < $line ) || echo "Failed"
done
