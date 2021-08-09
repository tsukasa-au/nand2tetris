#!/bin/bash

cd "$(dirname "$0")"

for i in *.tst; do
  echo "Running ${i}"
  ../../tools/HardwareSimulator.sh "$i"
done
