# Dotfiles - symlink packages into $HOME with GNU Stow

PACKAGES := fish git ghostty starship yazi emacs
STOW     := stow --dir=$(CURDIR) --target=$(HOME) --verbose=1

.DEFAULT_GOAL := help
.PHONY: help install stow unstow restow dry-run update

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "} /^[a-z-]+:.*## / {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install packages for this OS, then stow
	@./install.sh

stow: ## Symlink all packages into $(HOME)
	$(STOW) $(PACKAGES)

unstow: ## Remove all symlinks
	$(STOW) --delete $(PACKAGES)

restow: ## Re-stow after adding or removing files
	$(STOW) --restow $(PACKAGES)

dry-run: ## Show what stow would do without changing anything
	$(STOW) --no --verbose=2 $(PACKAGES)

update: ## git pull + restow
	git -C $(CURDIR) pull --rebase
	$(MAKE) restow
