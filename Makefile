SCRIPTS        = qemu-binfmt.initd qemu.initd qemush

prefix        := /usr/local
bindir        := $(prefix)/bin
sysconfdir    := /etc

INITD_DIR     := $(sysconfdir)/init.d
CONFD_DIR     := $(sysconfdir)/conf.d

INSTALL       := install
GIT           := git
SED           := sed


#: Print list of targets.
help:
	@printf '%s\n\n' 'List of targets:'
	@$(SED) -En '/^#:.*/{ N; s/^#: (.*)\n([A-Za-z0-9_-]+).*/\2 \1/p }' $(MAKEFILE_LIST) \
		| while read label desc; do printf '%-20s %s\n' "$$label" "$$desc"; done

#: Install the scripts and configuration file.
install: $(SCRIPTS) qemu.confd
	$(INSTALL) -m 755 -D qemu.initd "$(DESTDIR)$(INITD_DIR)/qemu"
	$(INSTALL) -m 755 -D qemu-binfmt.initd "$(DESTDIR)$(INITD_DIR)/qemu-binfmt"
	$(INSTALL) -m 644 -D qemu.confd "$(DESTDIR)$(CONFD_DIR)/qemu"
	$(INSTALL) -m 755 -D qemush "$(DESTDIR)$(bindir)/qemush"

#: Remove the scripts and configuration file.
uninstall:
	rm -f "$(DESTDIR)$(INITD_DIR)/qemu"
	rm -f "$(DESTDIR)$(INITD_DIR)/qemu-binfmt"
	rm -f "$(DESTDIR)$(CONFD_DIR)/qemu"
	rm -f "$(DESTDIR)$(bindir)/qemush"

#: Update version in the scripts to $VERSION.
bump-version:
	test -n "$(VERSION)"  # $$VERSION
	$(SED) -E -i "s/^(VERSION)=.*/\1='$(VERSION)'/" $(SCRIPTS)

#: Bump version to $VERSION, create release commit and tag.
release: .check-git-clean | bump-version
	test -n "$(VERSION)"  # $$VERSION
	$(GIT) add .
	$(GIT) commit -m "Release version $(VERSION)"
	$(GIT) tag -s v$(VERSION) -m v$(VERSION)


.check-git-clean:
	@test -z "$(shell $(GIT) status --porcelain)" \
		|| { echo 'You have uncommitted changes!' >&2; exit 1; }

.PHONY: help install uninstall bump-version release .check-git-clean
