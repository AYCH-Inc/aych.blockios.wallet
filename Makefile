#!/usr/bin/xcrun make -f

.PHONY: all install

all:
	install

install:
	sh scripts/install-dependencies.sh