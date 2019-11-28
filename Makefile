.PHONY: all
all: fmt lint

.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: lint
lint:
	tflint
