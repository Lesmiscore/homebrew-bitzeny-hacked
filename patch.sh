#!/bin/bash
set +e
cat "$1" | grep -v "^#" | grep -v "^$" | while read line ; do
  echo "Patching $line"
  wget -qO- "$line" | patch -p1 || echo "Failed"
done
