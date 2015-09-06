# -*- mode:makefile-gmake; mode:folding -*-

SHELL = /bin/bash
INSTALL = /usr/bin/install
INSTALL_DIRS = $(INSTALL) --directory
INSTALL_PROG = $(INSTALL)
INSTALL_DATA = $(INSTALL) --mode=644
GAWK = $(shell which gawk)

include help-system.mak

setpath = PATH=.:$$PATH
PKG=$(notdir $(abspath .))


styles   = $(addsuffix .sty,knoweb typesetcomments)
filters  = indexsymbols inlinecomments multilinecomments stripmodeline
autodefs = $(addprefix autodefs.,generic elisp maple matlab python)
pdfs     = $(addsuffix .pdf,knoweb indexsymbols stripmodeline typesetcomments autodefs)
bbls     = $(addsuffix .bbl,$(basename $(pdfs)))
man1pages = indexsymbols.1 inlinecomments.1 multilinecomments.1 stripmodeline.1 
man7pages = knowebstyle.7
manpages  = $(man1pages) $(man7pages)

installs = $(filters) $(styles) $(manpages) $(autodefs)

.PHONY: all pdf targets

scripts: $(call print-help,scripts,	extract all scripts)
scripts: $(installs)

pdf: $(call print-help,pdf,	generate the pdfs)
pdf: $(pdfs)

targets:
	@echo 'The following are valid targets:'
	@grep '^[a-z]\+:' Makefile

# {{{ filters

# 1. Extract the script from the noweb source.
# 2. Replace /usr/bin/gawk with actual location of gawk.
# 3. Make the script executable.

define build
   notangle -R$@ $< > $@
   sed "1s|/usr/bin/gawk|$(GAWK)|" -i $@
   chmod +x $@
endef

$(autodefs): autodefs.nw
	$(call build)

%: %.nw
	$(call build)

inlinecomments multilinecomments: typesetcomments.nw
	$(call build)

# }}}
# {{{ documentation

stripmodeline.tex: stripmodeline.nw stripmodeline
	$(setpath);\
	noweave \
	  -filter stripmodeline \
          -filter 'elide manpage*' \
	  -filter 'inlinecomments commentre="%[|]" commentshow="%"' \
	  -delay -index $< > $@

indexsymbols.tex:      \
  indexsymbols.nw      \
  indexsymbols         \
  simple.nw 	       \
  simple-markup        \
  simple-indexsymbols  \
  simple-diff 	       
	$(setpath);\
	noweave \
	  -filter stripmodeline \
	  -filter 'elide manpage*' \
	  -delay -index $< > $@

simple.nw: indexsymbols.nw
	notangle -R$@ $< > $@

show-markup: indexsymbols.nw
	notangle -R$@ $< > $@
	chmod +x $@

simple-markup: show-markup
	./$<

show-indexsymbols: indexsymbols.nw
	notangle -R$@ $< > $@
	chmod +x $@

simple-indexsymbols: show-indexsymbols
	$(setpath);\
	./$<

show-diff: indexsymbols.nw
	notangle -R$@ $< > $@
	chmod +x $@

simple-diff: show-diff simple-markup simple-indexsymbols
	-./$<

%.sty: %.nw
	notangle -R$@ $< > $@

knoweb.tex: knoweb.nw stripmodeline inlinecomments
%.tex: %.nw
	$(setpath);\
	noweave \
	  -filter stripmodeline \
	  -filter 'elide manpage:*' \
	  -filter 'inlinecomments commentre="%[|]" commentshow="%"' \
	  -delay -index $< > $@

%.aux: %.tex knoweb.sty
	pdflatex $<

.PHONY: bbl

bbl: $(bbls)
# this is tricky; it only needs to be executed once, but ...
%.bbl:
	bibtex $(basename $<)

%.pdf: %.tex %.aux # %.bbl
	pdflatex $<
	pdflatex $<

# }}}
# {{{ manpages

# Extract a manpage from a noweb source file
define make-manpage
  notangle -R'manpage: $@' $< > $@
endef

inlinecomments.1: typesetcomments.nw
	$(call make-manpage)

multilinecomments.1: typesetcomments.nw
	$(call make-manpage)

%.1: %.nw
	$(call make-manpage)

knowebstyle.7: knoweb.nw
	$(call make-manpage)

# }}}

# {{{ directories

# Assign variables specifying the installation directions

prefix ?= /usr/local

texdir = $(DESTDIR)$(prefix)/share/texmf/tex/latex
bindir = $(DESTDIR)$(prefix)/bin
docdir = $(DESTDIR)$(prefix)/share/doc/noweb-extras
mandir = $(DESTDIR)$(prefix)/share/man
mandirs = $(mandir)/man1 $(mandir)/man7
nwdir   = /usr/lib/noweb

.PHONY: installdirs

installdirs: 
	$(INSTALL_DIRS) $(texdir) $(bindir) $(docdir) $(nwdir) $(mandirs)

# }}}

# {{{ install

.PHONY: install install-pdf

install: $(call print-help,install,	install everything) 
install: $(installs) $(pdfs) installdirs
	$(INSTALL_PROG) $(filters) $(bindir)
	$(INSTALL_PROG) $(autodefs) $(nwdir)
	$(INSTALL_DATA) $(styles)   $(texdir)
	$(INSTALL_DATA) README.md COPYRIGHT $(pdfs) $(docdir)
	-$(INSTALL_DATA) $(man1pages) $(mandir)/man1
	-$(INSTALL_DATA) $(man7pages) $(mandir)/man7


# }}}
# {{{ uninstall

.PHONY: uninstall

uninstall: $(call print-help,uninstall,uninstall everything)
uninstall:
	$(RM) $(addprefix $(bindir)/,$(filters))
	$(RM) $(addprefix $(docdir)/,$(pdfs) README.md)
	$(RM) $(addprefix $(texdir)/,$(styles))
	$(RM) $(addprefix $(nwdir)/,$(autodefs))
	$(RM) $(addprefix $(mandir)/man1/,$(man1pages))
	$(RM) $(addprefix $(mandir)/man7/,$(man7pages))
# }}}

# {{{ dist

help: $(call print-separator)

.PHONY: dist

nwsrc = $(addsuffix .nw,knoweb indexsymbols simple stripmodeline typesetcomments $(autodefs))
save = $(nwsrc) $(bbls) README.md COPYRIGHT Makefile

knoweb.zip: $(save)
	zip $@ $?

dist: $(call print-help,dist,	create $(PKG).tar.gz)
dist: $(PKG).tar.gz

$(PKG).tar.gz: $(save)
	( cd ..; \
	  tar --exclude $(PKG)/$@ -cvzf $(PKG)/$@ $(addprefix $(PKG)/,$^) \
	)

# }}}
# {{{ clean

help: $(call print-separator)

.PHONY: clean cleanmost distclean maintainer-clean

clean: $(call print-help,clean,	remove tex auxiliary files)
clean: 
	$(RM) *~ *.dvi *.aux *.log *.blg *.toc *.out *.brf

cleanmost: $(call print-help,cleanmost,clean and remove most files)
cleanmost: clean
	$(RM) show-markup simple-markup show-indexsymbols simple-indexsymbols show-diff simple-diff

distclean: $(call print-help,distclean,cleanmost and remove all generated files)
distclean: cleanmost
	$(RM) $(filters) $(autodefs) $(manpages) *.pdf *.el *.tex *.sty

maintainer-clean: distclean
	$(RM) *.bbl

# }}}
