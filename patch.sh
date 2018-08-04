#!/bin/bash

cat "$1" | grep -v "^#" | grep -v "^$" | while read line ; do
  wget -qO- "$line" | patch -p1
done
