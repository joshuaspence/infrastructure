.PHONY: all
all: fmt

.PHONY: fmt
fmt:
	terraform fmt -recursive
