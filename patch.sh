#!/bin/bash
set +e
export PATCH_DIRS=""
if ! [ -z "$PATCHES" ] ; then
  export PATCH_DIRS="/patches/$PATCHES"
fi
if ! [ -z "$BINARY" ] ; then
  export PATCH_DIRS="$PATCH_DIRS /patches/$BINARY"
fi
if [ -z "$PATCH_DIRS" ] ; then
  exit 0
fi

find $PATCH_DIRS -type f | sort | while read line ; do
  echo "Patching $line"
  ( patch -p1 < $line ) || echo "Failed"
done
