Noweb Extensions
================

This package, noweb-extra, provides extensions to the noweb package.

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
The **autodefs.generic** script can be used with an arbitrary language
but requires a regular expression.

* **autodefs.elisp**
* **autodefs.generic**
* **autodefs.maple**
* **autodefs.matlab**
* **autodefs.python**

LaTeX Styles
------------

* **knoweb.sty** : improvement of noweb.sty

Installation
------------

The source for knoweb.sty, and associated gawk scripts (for the filters)
are noweb source files.  To tangle them, do

 `make all`

To create the pdfs that document the source, do

 `make pdf`

To install everything, check that the Makefile puts things
where you expect, then do

 `make install`


-- Joe Riel <joer@san.rr.com>
