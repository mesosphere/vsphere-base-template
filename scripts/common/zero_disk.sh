#!/bin/bash -eux

dd if=/dev/zero of=wipefile bs=1024x1024 || true
rm wipefile
