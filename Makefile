MAIN ?= main
BUILD_DIR ?= build
LATEXMK ?= latexmk
LATEXMK_FLAGS ?= -pdf -interaction=nonstopmode -halt-on-error -file-line-error -silent
ARTIFACT_MANIFEST ?= docs/artifact-manifest.md

BUILD_PDF := $(BUILD_DIR)/$(MAIN).pdf
ROOT_PDF := $(MAIN).pdf
BUILD_LOG := $(BUILD_DIR)/latexmk.stdout

.PHONY: all pdf clean watch distclean artifact-status

all: pdf

pdf:
	@mkdir -p $(BUILD_DIR)
	@$(LATEXMK) $(LATEXMK_FLAGS) -outdir=$(BUILD_DIR) $(MAIN).tex > $(BUILD_LOG) 2>&1 || { tail -n 80 $(BUILD_LOG); exit 1; }
	@test -f $(BUILD_PDF)
	@cmp -s $(BUILD_PDF) $(ROOT_PDF) || cp $(BUILD_PDF) $(ROOT_PDF)
	@printf 'Published %s\n' $(ROOT_PDF)

$(ROOT_PDF): pdf ;

watch:
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(LATEXMK_FLAGS) -pvc -outdir=$(BUILD_DIR) $(MAIN).tex

artifact-status:
	@test -f "$(ARTIFACT_MANIFEST)" || { printf 'Missing %s\n' "$(ARTIFACT_MANIFEST)"; exit 1; }
	@printf 'Artifact manifest: %s\n\n' "$(ARTIFACT_MANIFEST)"
	@awk 'BEGIN { show = 0 } /^## Current Status/ { show = 1 } /^## Claim-Status Map/ { exit } show { print }' "$(ARTIFACT_MANIFEST)"
	@printf '\nClaim-status map: %s#claim-status-map\n' "$(ARTIFACT_MANIFEST)"

clean:
	$(LATEXMK) -c -outdir=$(BUILD_DIR) $(MAIN).tex

distclean:
	$(LATEXMK) -C -outdir=$(BUILD_DIR) $(MAIN).tex
	rm -rf $(BUILD_DIR)
