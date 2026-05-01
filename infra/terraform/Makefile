SHELL  := /usr/bin/env bash
ENVS   := dev prod
TF     := terraform
PLANS  := $(CURDIR)/tfplans

.DEFAULT_GOAL := help

.PHONY: help fmt validate $(foreach e,$(ENVS),init-$(e) plan-$(e) apply-$(e) destroy-$(e) graph-$(e) validate-$(e) output-$(e))

help:
	@echo "DevOps Factory — Terraform targets"
	@echo ""
	@echo "  make fmt               Format all .tf files (recursive)"
	@echo "  make validate          Validate all environments"
	@echo ""
	@echo "  make init-<env>        terraform init"
	@echo "  make plan-<env>        terraform plan  (saves to tfplans/<env>.tfplan)"
	@echo "  make apply-<env>       terraform apply (requires saved plan)"
	@echo "  make destroy-<env>     terraform destroy (interactive confirmation)"
	@echo "  make graph-<env>       Generate SVG dependency graph"
	@echo "  make output-<env>      Show all outputs (sensitive values redacted)"
	@echo ""
	@echo "  Environments: $(ENVS)"

# ── Formatting ────────────────────────────────────────────────────────────────

fmt:
	@echo "==> Running terraform fmt (recursive)"
	@$(TF) fmt -recursive .

# ── Per-environment targets ───────────────────────────────────────────────────

define ENV_TARGETS
.PHONY: init-$(1) plan-$(1) apply-$(1) destroy-$(1) graph-$(1) validate-$(1) output-$(1)

init-$(1):
	@echo "==> Init [$(1)]"
	$(TF) -chdir=environments/$(1) init -upgrade

validate-$(1): init-$(1)
	@echo "==> Validate [$(1)]"
	$(TF) -chdir=environments/$(1) validate

plan-$(1): init-$(1)
	@echo "==> Plan [$(1)]"
	@mkdir -p $(PLANS)
	$(TF) -chdir=environments/$(1) plan \
		-out=$(PLANS)/$(1).tfplan \
		-detailed-exitcode

apply-$(1):
	@test -f $(PLANS)/$(1).tfplan || (echo "ERROR: no saved plan found — run make plan-$(1) first" && exit 1)
	@echo "==> Apply [$(1)] — applying saved plan"
	$(TF) -chdir=environments/$(1) apply $(PLANS)/$(1).tfplan

destroy-$(1): init-$(1)
	@echo "WARNING: About to DESTROY the [$(1)] environment."
	@echo "This is irreversible. Type '$(1)' to confirm:"
	@read confirm && [ "$$confirm" = "$(1)" ] || (echo "Aborted." && exit 1)
	$(TF) -chdir=environments/$(1) destroy

graph-$(1): init-$(1)
	@echo "==> Generating graph [$(1)]"
	@mkdir -p $(CURDIR)/docs
	$(TF) -chdir=environments/$(1) graph | dot -Tsvg > $(CURDIR)/docs/graph-$(1).svg
	@echo "==> Graph written to docs/graph-$(1).svg"

output-$(1):
	@echo "==> Outputs [$(1)]"
	$(TF) -chdir=environments/$(1) output
endef

$(foreach e,$(ENVS),$(eval $(call ENV_TARGETS,$(e))))

# ── Aggregate targets ─────────────────────────────────────────────────────────

validate: $(foreach e,$(ENVS),validate-$(e))
	@echo "==> All environments valid"
