.PHONY: all
all: fmt validate lint

.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: lint
lint:
	tflint

.PHONY: validate
validate:
	terraform validate
