.PHONY: test

cwd=$(shell pwd)

test:
	@PATH=$(cwd):${PATH} bats tests/*.bats
