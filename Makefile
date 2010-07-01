# -*- mode:makefile-gmake; mode:folding -*-

SHELL = /bin/bash
INSTALL = /usr/bin/install
INSTALL_DIRS = $(INSTALL) --directory
INSTALL_PROG = $(INSTALL)
INSTALL_DATA = $(INSTALL) --mode=644
GAWK = $(shell which gawk)

setpath = PATH=.:$$PATH
PKG=$(notdir $(abspath .))
# $(info Makefile for $(PKG))

styles   = $(addsuffix .sty,knoweb typesetcomments)
filters  = indexsymbols inlinecomments multilinecomments stripmodeline
#autodefs = $(addprefix autodefs.,generic elisp maple matlab python)
autodefs = $(addprefix autodefs.,generic elisp maple)
pdfs     = $(addsuffix .pdf,knoweb indexsymbols stripmodeline typesetcomments $(autodefs))
bbls     = $(addsuffix .bbl,$(basename $(pdfs)))
man1pages = indexsymbols.1 inlinecomments.1 multilinecomments.1 stripmodeline.1 
man7pages = knowebstyle.7
manpages  = $(man1pages) $(man7pages)

installs = $(filters) $(styles) $(manpages) $(autodefs)

.PHONY: all pdf targets
all: $(installs)
pdf: $(pdfs)

targets:
	@echo 'The following are valid targets:'
	@grep '^[a-z]\+:' Makefile

# {{{ filters

# 1. Insert a pound-bang line that specifies the location of gawk.
# 2. Append the script extracted from the noweb source.
# 3. Make the script executable.

define addawk
   echo "#!$(GAWK) --file" > $@
   notangle -R$@ $< >> $@
   chmod +x $@
endef

$(autodefs): autodefs.nw
	$(call addawk)

%: %.nw
	$(call addawk)

inlinecomments multilinecomments: typesetcomments.nw
	$(call addawk)


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
nwdir  = $(DESTDIR)$(prefix)/lib/noweb
mandir = $(DESTDIR)$(prefix)/share/man
mandirs = $(mandir)/man1 $(mandir)/man7

.PHONY: installdirs

installdirs: 
	$(INSTALL_DIRS) $(texdir) $(bindir) $(docdir) $(nwdir) $(mandirs)

# }}}

# {{{ install

.PHONY: install install-pdf

install: $(installs) installdirs
	$(INSTALL_PROG) $(filters) $(bindir)
	$(INSTALL_PROG) $(autodefs) $(nwdir)
	$(INSTALL_DATA) $(styles)   $(texdir)
	$(INSTALL_DATA) README COPYRIGHT $(docdir)
	-$(INSTALL_DATA) $(man1pages) $(mandir)/man1
	-$(INSTALL_DATA) $(man7pages) $(mandir)/man7

install-pdf: $(pdfs) installdirs
	$(INSTALL_DATA) $(pdfs) README $(docdir)

# }}}
# {{{ uninstall

.PHONY: uninstall
uninstall:
	$(RM) $(addprefix $(bindir)/,$(filters))
	$(RM) $(addprefix $(docdir)/,$(pdfs) README)
	$(RM) $(addprefix $(texdir)/,$(styles))
	$(RM) $(addprefix $(nwdir)/,$(autodefs))
	$(RM) $(addprefix $(mandir)/man1/,$(man1pages))
	$(RM) $(addprefix $(mandir)/man7/,$(man7pages))
# }}}

# {{{ dist

.PHONY: dist

nwsrc = $(addsuffix .nw,knoweb indexsymbols simple stripmodeline typesetcomments $(autodefs))
save = $(nwsrc) $(bbls) README COPYRIGHT Makefile

nada: $(save)
#$(info $(save))

knoweb.zip: $(save)
	zip $@ $?

dist: $(PKG).tar.gz

$(PKG).tar.gz: $(save)
	( cd ..; \
	  tar --exclude $(PKG)/$@ -cvzf $(PKG)/$@ $(addprefix $(PKG)/,$^) \
	)

# }}}
# {{{ clean

.PHONY: clean cleanmost distclean maintainer-clean
clean: 
	$(RM) *~ *.dvi *.aux *.log *.blg *.toc *.out *.brf

cleanmost: clean
	$(RM) show-markup simple-markup show-indexsymbols simple-indexsymbols show-diff simple-diff

distclean: cleanmost
	$(RM) $(filters) $(autodefs) $(manpages) *.pdf *.el *.tex *.sty

maintainer-clean: distclean
	$(RM) *.bbl

# }}}