<!--*- markdown -*-->
Noweb Extensions
================

This package provides extensions to the [noweb](https://github.com/nrnrnr/noweb) package.

LaTeX Styles
------------

* **knoweb.sty** : improvement of noweb.sty.

Miscellaneous Filters
---------------------

* **indexsymbols** : extends the btdefn filter to permit manually index symbols
* **inlinecomments** : typeset inline comments
* **multilinecomments** : typeset multiline comments
* **stripmodeline** : strip an emacs mode-line from generated noweb files

Autodef Filters
---------------

Generate noweb indices from noweb source files.
The following gawk scripts generate indices for particular languages.

* **autodefs.bash**
* **autodefs.elisp**
* **autodefs.maple**
* **autodefs.matlab**
* **autodefs.python**

Installation
------------

The source for `knoweb.sty`, and associated gawk scripts (for the filters)
are noweb source files.  To tangle them, do

 `make scripts`

To create the pdfs that document the source, do

 `make pdf`

To install everything, check that the Makefile puts things
where you expect, then do

 `make install`


-- Joe Riel <joer@san.rr.com>
