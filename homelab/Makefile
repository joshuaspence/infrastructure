HOST ?= all

.PHONY: list
list:
	ansible --list-hosts $(HOST)

.PHONY: ping
ping:
	ansible --module-name ping $(HOST)

.PHONY: playbook
playbook:
	ansible-playbook playbooks/$(PLAYBOOK).yaml

.PHONY: requirements
requirements:
	ansible-galaxy install --role-file requirements.yaml
